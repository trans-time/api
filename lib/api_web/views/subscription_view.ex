defmodule ApiWeb.SubscriptionView do
  use ApiWeb, :view
  use JaSerializer.PhoenixView
  alias ApiWeb.{SubscriptionTypeView, UserView}

  attributes [:name]

  def preload(record_or_records, _conn, include_opts) do
    Api.Repo.preload(record_or_records, include_opts)
  end

  def relationships(user, _conn) do
    Enum.reduce([
      %{key: :subscription_types, view: SubscriptionView},
      %{key: :user, view: UserView}
    ], %{}, fn(relationship, relationships) ->
      if Ecto.assoc_loaded?(Map.get(user, relationship.key)) do
        Map.put(relationships, relationship.key, %HasMany{
          serializer: relationship.view,
          include: true,
          data: Map.get(user, relationship.key)
        })
      else
        relationships
      end
    end)
  end
end
