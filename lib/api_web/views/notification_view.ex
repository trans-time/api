import Ecto.Query, only: [from: 2]

defmodule ApiWeb.NotificationView do
  use ApiWeb, :view
  use JaSerializer.PhoenixView
  alias Api.Timeline.Comment
  alias ApiWeb.{NotificationCommentAtView, NotificationCommentView, NotificationTimelineItemAtView, UserView}

  attributes [:read, :seen]

  def preload(record_or_records, conn, _include_opts) do
    current_user_id = String.to_integer(Api.Accounts.Guardian.Plug.current_claims(conn)["sub"] || "-1")

    Api.Repo.preload(record_or_records, [
      :user,
      notification_comment: [
        timeline_item: [
          :user,
          comments: from(c in Comment,
            where: c.user_id != ^current_user_id and c.under_moderation == ^false and c.deleted == ^false,
            distinct: c.user_id,
            order_by: c.inserted_at,
            limit: 2,
            join: u in assoc(c, :user),
            preload: [user: u]
          )
        ]
      ],
      notification_comment_at: [
        comment: [:user]
      ],
      notification_timeline_item_at: [
        timeline_item: [:user]
      ]
    ])
  end

  def relationships(user, _conn) do
    Enum.reduce([
      %{key: :notification_comment_at, view: NotificationCommentAtView},
      %{key: :notification_comment, view: NotificationCommentView},
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
