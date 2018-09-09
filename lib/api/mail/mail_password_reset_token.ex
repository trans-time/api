import Ecto.Query

defmodule Api.Mail.MailPasswordResetToken do
  use Api.Schema
  import Ecto.Changeset
  alias Api.Accounts.User
  alias Api.Mail.MailPasswordResetToken


  schema "mail_password_reset_tokens" do
    field :token, :string

    belongs_to :user, User

    timestamps()
  end

  @doc false
  def changeset(%MailPasswordResetToken{} = mail_password_reset_token, attrs) do
    mail_password_reset_token
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
