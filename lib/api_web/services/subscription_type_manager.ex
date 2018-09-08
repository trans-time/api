import Ecto.Query

defmodule ApiWeb.Services.SubscriptionTypeManager do
  alias Api.Mail.SubscriptionType
  alias Ecto.Multi

  def get_or_insert(name) do
    Multi.new
    |> Multi.run("subscription_type_#{name}", fn _ ->
      subscription = Api.Repo.get_by(SubscriptionType, name: name)

      if (subscription) do
        {:ok, subscription}
      else
        Api.Repo.insert(SubscriptionType.changeset(%SubscriptionType{}, %{
          name: name
        }))
      end
    end)
  end
end
