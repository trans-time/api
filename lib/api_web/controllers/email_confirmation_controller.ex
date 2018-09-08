import Ecto.Query

defmodule ApiWeb.EmailConfirmationController do
  use ApiWeb, :controller
  use JaResource # Optionally put in web/web.ex
  plug JaResource
  alias Api.Accounts.User
  alias Api.Mail.{MailConfirmationToken, MailRecoveryToken}
  alias ApiWeb.Services.MailManager
  alias Ecto.Multi

  def model, do: User

  def handle_create(conn, _attributes) do
    mail_confirmation_token = Api.Repo.preload(Api.Repo.get_by(MailConfirmationToken, token: conn.params["mail_confirmation_token"]), [:user])
    user = mail_confirmation_token.user
    is_original_address = mail_confirmation_token.email != nil

    changeset = if (is_original_address), do: User.private_changeset(user, %{
      email: mail_confirmation_token.email,
      email_is_confirmed: true
    }), else: User.private_changeset(user, %{
      email_is_confirmed: true
    })

    multi = Multi.new
    |> Multi.update(:user, changeset)
    |> Multi.delete(:mail_confirmation_token, mail_confirmation_token)
    |> Multi.merge(fn args1 ->
      if (is_original_address) do
        Multi.new
        |> Multi.insert(:mail_recovery_token, MailRecoveryToken.changeset(%MailRecoveryToken{}, %{
          user_id: user.id,
          email: user.email
        }))
        |> Multi.merge(fn args2 ->
          MailManager.send(user, Map.merge(args1, args2), :mail_recovery)
        end)
      else
        Multi.new
      end
    end)

    transaction = Api.Repo.transaction(multi)
    if Kernel.elem(transaction, 0) === :ok, do: Kernel.elem(transaction, 1).user, else: transaction
  end
end
