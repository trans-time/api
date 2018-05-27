defmodule ApiWeb.TimelineItemView do
  use ApiWeb, :view
  use JaSerializer.PhoenixView
  alias ApiWeb.{CommentView, PostView, ReactionView, TagView, UserView}

  attributes [:date, :deleted, :private, :maturity_rating, :text, :comments_are_locked, :comment_count, :moon_count, :star_count, :sun_count, :under_moderation]

  def current_user_reaction(_params, _conn), do: nil

  def preload(record_or_records, _conn, include_opts) do
    Api.Repo.preload(record_or_records, include_opts)
  end

  def relationships(user, _conn) do
    Enum.reduce([
      %{key: :user, view: UserView},
      %{key: :comments, view: CommentView},
      %{key: :reactions, view: ReactionView},
      %{key: :tags, view: TagView},
      %{key: :users, view: UserView},
      %{key: :post, view: PostView}
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
