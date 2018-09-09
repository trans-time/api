import Ecto.Query

defmodule ApiWeb.EmailPasswordResetRequestController do
  use ApiWeb, :controller
  use JaResource # Optionally put in web/web.ex
  plug JaResource
  alias Api.Accounts.User
  alias Api.Mail.{MailPasswordResetToken}
  alias ApiWeb.Services.MailManager
  alias Ecto.Multi

  def model, do: User

  def handle_create(conn, attributes) do
    case Recaptcha.verify(attributes["re_captcha_response"]) do
      {:ok, response} ->
        user = User.get_user_by_identification(attributes["username"])

        multi = Multi.new
        |> Multi.insert(:mail_password_reset_token, MailPasswordResetToken.changeset(%MailPasswordResetToken{}, %{
          user_id: user.id
        }))
        |> Multi.merge(fn args ->
          MailManager.send(user, args, :password_reset)
        end)

        transaction = Api.Repo.transaction(multi)
        if Kernel.elem(transaction, 0) === :ok, do: user, else: transaction
      {:error, errors} -> invalid_recaptcha(conn)
    end
  end

  defp invalid_recaptcha(conn) do
    conn
    |> put_status(401)
    |> json(%{errors: [%{title: "remote.errors.title.invalid", detail: "remote.errors.detail.invalid.recaptcha", status: "401"}]})
  end
end
