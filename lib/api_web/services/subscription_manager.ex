import Ecto.Query

defmodule ApiWeb.Services.SubscriptionManager do
  alias Api.Mail.Subscription
  alias ApiWeb.Services.SubscriptionTypeManager
  alias Ecto.Multi

  def insert(subscription_type, user) do
    Multi.new
    |> Multi.run("subscription_#{subscription_type.name}", fn _ ->
      Api.Repo.insert(Subscription.changeset(%Subscription{}, %{
        subscription_type_id: subscription_type.id,
        user_id: user.id
      }))
    end)
  end

  def subscribe_to_all(types, user) do
    Enum.reduce(types, Multi.new, fn (type, multi) ->
      Multi.merge(multi, fn _ ->
        SubscriptionTypeManager.get_or_insert(type)
      end)
      |> Multi.merge(fn args ->
        subscription_type = args["subscription_type_#{type}"]
        insert(subscription_type, user)
      end)
    end)
  end
end
