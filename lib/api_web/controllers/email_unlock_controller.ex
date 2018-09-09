import Ecto.Query

defmodule ApiWeb.EmailUnlockController do
  use ApiWeb, :controller
  use JaResource # Optionally put in web/web.ex
  plug JaResource
  alias Api.Accounts.User
  alias Api.Mail.{MailUnlockToken}
  alias Ecto.Multi

  def model, do: User

  def handle_create(conn, _attributes) do
    mail_unlock_token = Api.Repo.preload(Api.Repo.get_by(MailUnlockToken, token: conn.params["mail_unlock_token"]), [:user])
    user = mail_unlock_token.user

    changeset = User.private_changeset(user, %{
      is_locked: false,
      consecutive_failed_logins: 0
    })

    multi = Multi.new
    |> Multi.update(:user, changeset)
    |> Multi.delete(:mail_unlock_token, mail_unlock_token)

    transaction = Api.Repo.transaction(multi)
    if Kernel.elem(transaction, 0) === :ok, do: Kernel.elem(transaction, 1).user, else: transaction
  end
end
