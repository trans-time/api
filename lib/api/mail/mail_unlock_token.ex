import Ecto.Query

defmodule Api.Mail.MailUnlockToken do
  use Api.Schema
  import Ecto.Changeset
  alias Api.Accounts.User
  alias Api.Mail.MailUnlockToken


  schema "mail_unlock_tokens" do
    field :token, :string

    belongs_to :user, User
  end

  @doc false
  def changeset(%MailUnlockToken{} = mail_unlock_token, attrs) do
    mail_unlock_token
    |> cast(attrs, [:user_id])
    |> validate_required([:user_id])
    |> assoc_constraint(:user)
    |> generate_mail_token()
  end

  defp generate_mail_token(changeset) do
    token = Ecto.UUID.generate()
    put_change changeset, :token, token
  end
end
