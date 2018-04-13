defmodule ApiWeb.PostView do
  use ApiWeb, :view
  use JaSerializer.PhoenixView
  alias ApiWeb.{ImageView, ReactionView, TimelineItemView}

  attributes [:nsfw, :text, :comment_count, :moon_count, :star_count, :sun_count]

  has_one :timeline_item,
    serializer: TimelineItemView,
    include: false

  has_many :images,
    serializer: ImageView

  has_many :reactions,
    serializer: ReactionView

  def preload(record_or_records, _conn, include_opts) do
    Api.Repo.preload(record_or_records, include_opts)
  end

  def relationships(user, _conn) do
    Enum.reduce([
      %{key: :images, view: ImageView},
      %{key: :reactions, view: ReactionView},
      %{key: :timeline_item, view: TimelineItemView}
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
