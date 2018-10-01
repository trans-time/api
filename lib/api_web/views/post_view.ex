defmodule ApiWeb.PostView do
  use ApiWeb, :view
  use JaSerializer.PhoenixView
  alias ApiWeb.{ImageView, ReactionView, TextVersionView, TimelineItemView}

  attributes [:short_text, :text]

  def attributes(post, conn) do
    if (Map.has_key?(post, :text)) do
      super(post, conn)
    else
      super(post, conn)
      |> Map.take([:short_text])
    end
  end

  def preload(record_or_records, _conn, include_opts) do
    Api.Repo.preload(record_or_records, include_opts)
  end

  def relationships(user, _conn) do
    Enum.reduce([
      %{key: :images, view: ImageView},
      %{key: :text_versions, view: TextVersionView},
      %{key: :timeline_item, view: TimelineItemView}
    ], %{}, fn(relationship, relationships) ->
      if Ecto.assoc_loaded?(Map.get(user, relationship.key)) && Map.get(user, relationship.key) != nil do
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
