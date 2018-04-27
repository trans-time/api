defmodule ApiWeb.UserTagSummaryUserView do
  use ApiWeb, :view
  use JaSerializer.PhoenixView
  alias ApiWeb.{UserTagSummaryView, UserView}

  attributes [:timeline_item_ids]

  def preload(record_or_records, _conn, include_opts) do
    Api.Repo.preload(record_or_records, :user)
  end

  def relationships(user, _conn) do
    Enum.reduce([
      %{key: :user, view: UserView},
      %{key: :user_tag_summary, view: UserTagSummaryView}
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
