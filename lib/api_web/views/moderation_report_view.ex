defmodule ApiWeb.ModerationReportView do
  use ApiWeb, :view
  use JaSerializer.PhoenixView
  alias ApiWeb.{CommentView, PostView, FlagView, UserView}

  attributes [:inserted_at, :moderator_comment, :was_violation, :resolved, :action_banned_user, :action_deleted_flaggable, :action_ignore_flags, :action_lock_comments, :ban_user_until, :lock_comments_until]

  def preload(record_or_records, _conn, include_opts) do
    Api.Repo.preload(record_or_records, include_opts)
  end

  def relationships(flag, _conn) do
    Enum.reduce([
      %{key: :comment, view: CommentView},
      %{key: :post, view: PostView},
      %{key: :indicted, view: UserView},
      %{key: :moderator, view: UserView},
      %{key: :flags, view: FlagView}
    ], %{}, fn(relationship, relationships) ->
      if Ecto.assoc_loaded?(Map.get(flag, relationship.key)) do
        Map.put(relationships, relationship.key, %HasMany{
          serializer: relationship.view,
          include: true,
          data: Map.get(flag, relationship.key)
        })
      else
        relationships
      end
    end)
  end
end
