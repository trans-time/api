import Ecto.Query

defmodule ApiWeb.EmailRecoveryController do
  use ApiWeb, :controller
  use JaResource # Optionally put in web/web.ex
  plug JaResource
  alias Api.Accounts.User
  alias Api.Mail.{MailRecoveryToken}

  def model, do: User

  def handle_create(conn, _attributes) do
    mail_recovery_token = Api.Repo.preload(Api.Repo.get_by(MailRecoveryToken, token: conn.params["mail_recovery_token"]), [:user])
    user = mail_recovery_token.user

    changeset = User.public_update_changeset(user, %{
      email: mail_recovery_token.email
    })

    Api.Repo.update(changeset)
  end
end
