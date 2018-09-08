import Ecto.Query

defmodule Api.Mail.SubscriptionType do
  use Api.Schema
  import Ecto.Changeset
  alias Api.Mail.{Subscription, SubscriptionType}


  schema "subscription_types" do
    field :name, :string

    has_many :subscriptions, Subscription
  end

  @doc false
  def changeset(%SubscriptionType{} = subscription_type, attrs) do
    subscription_type
    |> cast(attrs, [:name])
  end
end
