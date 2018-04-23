defmodule ApiWeb.CommentView do
  use ApiWeb, :view
  use JaSerializer.PhoenixView
  alias ApiWeb.{CommentView, PostView, ReactionView, TextVersionView, UserView}

  attributes [:inserted_at, :deleted, :text, :comment_count, :moon_count, :star_count, :sun_count]

  def preload(record_or_records, _conn, include_opts) do
    Api.Repo.preload(record_or_records, include_opts)
  end

  def relationships(user, _conn) do
    Enum.reduce([
      %{key: :children, view: CommentView},
      %{key: :parent, view: CommentView},
      %{key: :post, view: PostView},
      %{key: :reactions, view: ReactionView},
      %{key: :text_versions, view: TextVersionView},
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
