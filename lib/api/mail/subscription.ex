import Ecto.Query

defmodule Api.Mail.Subscription do
  use Api.Schema
  import Ecto.Changeset
  alias Api.Accounts.User
  alias Api.Mail.{Subscription, SubscriptionType}


  schema "subscriptions" do
    belongs_to :user, User
    belongs_to :subscription_type, SubscriptionType
  end

  @doc false
  def changeset(%Subscription{} = subscription, attrs) do
    subscription
    |> cast(attrs, [:subscription_type_id, :user_id])
    |> validate_required([:subscription_type_id, :user_id])
    |> assoc_constraint(:subscription_type)
    |> assoc_constraint(:user)
  end
end
