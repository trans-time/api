import Ecto.Query

defmodule Api.Mail.MailConfirmationToken do
  use Api.Schema
  import Ecto.Changeset
  alias Api.Accounts.User
  alias Api.Mail.MailConfirmationToken


  schema "mail_confirmation_tokens" do
    field :token, :string
    field :email, :string
    field :reminder_was_sent, :boolean, default: false

    belongs_to :user, User
  end

  @doc false
  def changeset(%MailConfirmationToken{} = mail_confirmation_token, attrs) do
    mail_confirmation_token
    |> cast(attrs, [:user_id, :email, :reminder_was_sent])
    |> validate_required([:user_id, :reminder_was_sent])
    |> assoc_constraint(:user)
    |> validate_length(:email, max: 1000, message: "remote.errors.detail.length.length")
    |> validate_format(:email, ~r/^[A-Za-z0-9._%+-+']+@[A-Za-z0-9.-]+\.[A-Za-z]+$/, message: "remote.errors.detail.format.email")
    |> validate_new_email_is_unique()
    |> generate_mail_token()
  end

  defp generate_mail_token(changeset) do
    token = Ecto.UUID.generate()
    put_change changeset, :token, token
  end

  defp validate_new_email_is_unique(changeset, _opts \\ []) do
    validate_change(changeset, :email, fn :email, email ->
      user = Api.Repo.get_by(User, email: email)

      if (user) do
        [email: "remote.errors.detail.email.unique"]
      else
        []
      end
    end)
  end
end
