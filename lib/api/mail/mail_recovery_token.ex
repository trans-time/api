import Ecto.Query

defmodule Api.Mail.MailRecoveryToken do
  use Api.Schema
  import Ecto.Changeset
  alias Api.Accounts.User
  alias Api.Mail.MailRecoveryToken


  schema "mail_recovery_tokens" do
    field :token, :string
    field :email, :string

    belongs_to :user, User
  end

  @doc false
  def changeset(%MailRecoveryToken{} = mail_recovery_token, attrs) do
    mail_recovery_token
    |> cast(attrs, [:user_id, :email])
    |> validate_required([:user_id, :email])
    |> assoc_constraint(:user)
    |> generate_mail_token()
  end

  defp generate_mail_token(changeset) do
    token = Ecto.UUID.generate()
    put_change changeset, :token, token
  end
end
