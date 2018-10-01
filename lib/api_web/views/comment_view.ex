defmodule ApiWeb.CommentView do
  use ApiWeb, :view
  use JaSerializer.PhoenixView
  alias ApiWeb.{CommentView, TimelineItemView, ReactionView, TextVersionView, UserView}

  attributes [:inserted_at, :is_marked_for_deletion, :is_under_moderation, :short_text, :text, :comment_count, :moon_count, :star_count, :sun_count, :reaction_count]

  def attributes(comment, conn) do
    if (Map.has_key?(comment, :text)) do
      super(comment, conn)
    else
      super(comment, conn)
      |> Map.take([:short_text])
    end
  end

  def preload(record_or_records, _conn, include_opts) do
    Api.Repo.preload(record_or_records, include_opts)
  end

  def relationships(user, _conn) do
    Enum.reduce([
      %{key: :children, view: CommentView},
      %{key: :parent, view: CommentView},
      %{key: :timeline_item, view: TimelineItemView},
      %{key: :reactions, view: ReactionView},
      %{key: :text_versions, view: TextVersionView},
      %{key: :user, view: UserView}
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
