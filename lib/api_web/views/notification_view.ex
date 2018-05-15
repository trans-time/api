defmodule ApiWeb.NotificationView do
  use ApiWeb, :view
  use JaSerializer.PhoenixView
  alias ApiWeb.{NotificationCommentAtView,NotificationTimelineItemAtView,UserView}

  attributes [:read, :seen]

  def preload(record_or_records, _conn, include_opts) do
    Api.Repo.preload(record_or_records, include_opts)
  end

  def relationships(user, _conn) do
    Enum.reduce([
      %{key: :notification_comment_at, view: NotificationCommentAtView},
      %{key: :notification_timeline_item_at, view: NotificationTimelineItemAtView},
      %{key: :user, view: UserView},
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
