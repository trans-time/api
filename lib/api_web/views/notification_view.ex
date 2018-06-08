import Ecto.Query, only: [from: 2]

defmodule ApiWeb.NotificationView do
  use ApiWeb, :view
  use JaSerializer.PhoenixView
  alias Api.Relationship.Follow
  alias Api.Timeline.Reaction
  alias ApiWeb.{
    NotificationCommentAtView,
    NotificationCommentCommentView,
    NotificationCommentReactionView,
    NotificationFollowView,
    NotificationModerationRequestView,
    NotificationModerationResolutionView,
    NotificationPrivateGrantView,
    NotificationPrivateRequestView,
    NotificationTimelineItemAtView,
    NotificationTimelineItemCommentView,
    NotificationTimelineItemReactionView,
    UserView
  }

  attributes [:read, :seen]

  def preload(record_or_records, conn, _include_opts) do
    current_user_id = String.to_integer(Api.Accounts.Guardian.Plug.current_claims(conn)["sub"] || "-1")

    Api.Repo.preload(record_or_records, [
      :notification_moderation_request,
      :notification_private_request,
      notification_comment_at: [
        comment: [:user]
      ],
      notification_comment_comment: [
        comment: [
          :user,
          parent: [:user]
        ]
      ],
      notification_comment_reaction: [
        comment: [
          reactions: from(r in Reaction,
            where: r.user_id != ^current_user_id,
            order_by: r.inserted_at,
            limit: 2,
            join: u in assoc(r, :user),
            preload: [user: u]
          )
        ]
      ],
      notification_follow: [
        follow: [:follower]
      ],
      notification_moderation_resolution: [
        :flag
      ],
      notification_private_grant: [
        follow: [:followed]
      ],
      notification_timeline_item_at: [
        timeline_item: [:user]
      ],
      notification_timeline_item_comment: [
        comment: [
          :user,
          timeline_item: [:user]
        ]
      ],
      notification_timeline_item_reaction: [
        timeline_item: [
          reactions: from(r in Reaction,
            where: r.user_id != ^current_user_id,
            order_by: r.inserted_at,
            limit: 2,
            join: u in assoc(r, :user),
            preload: [user: u]
          )
        ]
      ]
    ])
  end

  def relationships(user, _conn) do
    Enum.reduce([
      %{key: :notification_comment_at, view: NotificationCommentAtView},
      %{key: :notification_comment_comment, view: NotificationCommentCommentView},
      %{key: :notification_comment_reaction, view: NotificationCommentReactionView},
      %{key: :notification_follow, view: NotificationFollowView},
      %{key: :notification_moderation_request, view: NotificationModerationRequestView},
      %{key: :notification_moderation_resolution, view: NotificationModerationResolutionView},
      %{key: :notification_private_grant, view: NotificationPrivateGrantView},
      %{key: :notification_private_request, view: NotificationPrivateRequestView},
      %{key: :notification_timeline_item_at, view: NotificationTimelineItemAtView},
      %{key: :notification_timeline_item_comment, view: NotificationTimelineItemCommentView},
      %{key: :notification_timeline_item_reaction, view: NotificationTimelineItemReactionView},
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
