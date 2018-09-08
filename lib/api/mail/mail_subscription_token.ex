import Ecto.Query

defmodule Api.Mail.MailSubscriptionToken do
  use Api.Schema
  import Ecto.Changeset
  alias Api.Accounts.User
  alias Api.Mail.MailSubscriptionToken


  schema "mail_subscription_tokens" do
    field :token, :string

    belongs_to :user, User

    timestamps()
  end

  @doc false
  def changeset(%MailSubscriptionToken{} = mail_subscription_token, attrs) do
    mail_subscription_token
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
