import Ecto.Query

defmodule ApiWeb.EmailPasswordResetController do
  use ApiWeb, :controller
  use JaResource # Optionally put in web/web.ex
  plug JaResource
  alias Api.Accounts.{User, UserPassword}
  alias Api.Mail.MailPasswordResetToken
  alias Ecto.Multi

  def model, do: User

  def handle_create(conn, attributes) do
    mail_password_reset_token = Api.Repo.preload(Api.Repo.get_by(MailPasswordResetToken, token: conn.params["mail_password_reset_token"]), [user: :user_password])
    user_password = mail_password_reset_token.user.user_password

    multi = Multi.new
    |> Multi.update(:user_password, UserPassword.public_update_changeset(user_password, %{password: attributes["password"]}))
    |> Multi.delete(:mail_password_reset_token, mail_password_reset_token)

    transaction = Api.Repo.transaction(multi)
    if Kernel.elem(transaction, 0) === :ok, do: mail_password_reset_token.user, else: transaction
  end
end
