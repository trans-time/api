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
  end
end
