import Ecto.Query

defmodule ApiWeb.EmailChangeController do
  use ApiWeb, :controller
  use JaResource # Optionally put in web/web.ex
  plug JaResource
  alias Api.Accounts.User
  alias Api.Mail.{MailConfirmationToken}
  alias ApiWeb.Services.MailManager
  alias Ecto.Multi

  def model, do: User

  def handle_create(conn, attributes) do
    user = Api.Accounts.Guardian.Plug.current_resource(conn)

    if User.validate_password(user, Map.get(attributes, "password")) do
      multi = Multi.new
      |> Multi.insert(:mail_confirmation_token, MailConfirmationToken.changeset(%MailConfirmationToken{}, %{
        user_id: user.id,
        email: attributes["email"]
      }))
      |> Multi.merge(fn args ->
        MailManager.send(user, args, :new_email_confirmation)
      end)

      transaction = Api.Repo.transaction(multi)
      if Kernel.elem(transaction, 0) === :ok, do: user, else: transaction
    else
      invalid_identity(conn)
    end
  end

  defp invalid_identity(conn) do
    conn
    |> put_status(401)
    |> json(%{errors: [%{title: "remote.errors.title.invalid", detail: "remote.errors.detail.invalid.password", status: "401"}]})
  end
end
