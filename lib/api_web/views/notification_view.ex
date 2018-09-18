import Ecto.Query, only: [from: 2]

defmodule ApiWeb.NotificationView do
  use ApiWeb, :view
  use JaSerializer.PhoenixView
  alias Api.Relationship.Follow
  alias Api.Timeline.{Comment, Post, Reaction}
  alias ApiWeb.{
    NotificationCommentAtView,
    NotificationCommentCommentView,
    NotificationCommentReactionView,
    NotificationCommentReactionV2View,
    NotificationEmailConfirmationView,
    NotificationFollowView,
    NotificationModerationRequestView,
    NotificationModerationResolutionView,
    NotificationModerationViolationView,
    NotificationPrivateGrantView,
    NotificationPrivateRequestView,
    NotificationTimelineItemAtView,
    NotificationTimelineItemCommentView,
    NotificationTimelineItemReactionView,
    NotificationTimelineItemReactionV2View,
    UserView
  }

  attributes [:is_read, :is_seen, :updated_at]

  def preload(record_or_records, conn, _include_opts) do
    current_user_id = String.to_integer(Api.Accounts.Guardian.Plug.current_claims(conn)["sub"] || "-1")

    Api.Repo.preload(record_or_records, [
      :notification_email_confirmation,
      :notification_moderation_request,
      :notification_private_request,
      notification_comment_at: [
        comment: [:user]
      ],
      notification_comment_comment: [
        comment: from(c in Comment,
          join: u in assoc(c, :user),
          join: p in assoc(c, :parent),
          join: pu in assoc(p, :user),
          select: %{
            id: c.id,
            text: fragment("LEFT(?, 50)", c.text),
            user: u,
            parent: %{
              id: p.id,
              user: pu
            }
          }
        )
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
      notification_comment_reaction_v2: [
        reaction: [
          :user,
          comment: from(c in Comment,
            select: %{
              id: c.id,
              text: fragment("LEFT(?, 50)", c.text)
            }
          )
        ]
      ],
      notification_follow: [
        follow: [:follower]
      ],
      notification_moderation_resolution: [
        :flag
      ],
      notification_moderation_violation: [
        :moderation_report
      ],
      notification_private_grant: [
        follow: [:followed]
      ],
      notification_timeline_item_at: [
        timeline_item: [:user, :post]
      ],
      notification_timeline_item_comment: [
        comment: [
          :user,
          timeline_item: [
            :user,
            post: from(p in Post,
              select: %{
                id: p.id,
                text: fragment("LEFT(?, 50)", p.text)
              }
            )
          ]
        ]
      ],
      notification_timeline_item_reaction: [
        timeline_item: [
          post: from(p in Post,
            select: %{
              id: p.id,
              text: fragment("LEFT(?, 50)", p.text)
            }
          ),
          reactions: from(r in Reaction,
            where: r.user_id != ^current_user_id,
            order_by: r.inserted_at,
            limit: 2,
            join: u in assoc(r, :user),
            preload: [user: u]
          )
        ]
      ],
      notification_timeline_item_reaction_v2: [
        reaction: [
          :user,
          timeline_item: [
            post: from(p in Post,
              select: %{
                id: p.id,
                text: fragment("LEFT(?, 50)", p.text)
              }
            )
          ]
        ]
      ]
    ])
  end

  def relationships(user, _conn) do
    Enum.reduce([
      %{key: :notification_comment_at, view: NotificationCommentAtView},
      %{key: :notification_comment_comment, view: NotificationCommentCommentView},
      %{key: :notification_comment_reaction, view: NotificationCommentReactionView},
      %{key: :notification_comment_reaction_v2, view: NotificationCommentReactionV2View},
      %{key: :notification_email_confirmation, view: NotificationEmailConfirmationView},
      %{key: :notification_follow, view: NotificationFollowView},
      %{key: :notification_moderation_request, view: NotificationModerationRequestView},
      %{key: :notification_moderation_resolution, view: NotificationModerationResolutionView},
      %{key: :notification_moderation_violation, view: NotificationModerationViolationView},
      %{key: :notification_private_grant, view: NotificationPrivateGrantView},
      %{key: :notification_private_request, view: NotificationPrivateRequestView},
      %{key: :notification_timeline_item_at, view: NotificationTimelineItemAtView},
      %{key: :notification_timeline_item_comment, view: NotificationTimelineItemCommentView},
      %{key: :notification_timeline_item_reaction, view: NotificationTimelineItemReactionView},
      %{key: :notification_timeline_item_reaction_v2, view: NotificationTimelineItemReactionV2View},
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
