defmodule Api.Notifications.Notification do
  use Api.Schema
  import Ecto.Changeset
  alias Api.Accounts.User
  alias Api.Notifications.{
    Notification,
    NotificationCommentAt,
    NotificationCommentComment,
    NotificationCommentReaction,
    NotificationFollow,
    NotificationModerationRequest,
    NotificationModerationResolution,
    NotificationPrivateGrant,
    NotificationPrivateRequest,
    NotificationTimelineItemComment,
    NotificationTimelineItemAt,
    NotificationTimelineItemReaction
  }


  schema "notifications" do
    field :read, :boolean, default: false
    field :seen, :boolean, default: false
    field :updated_at, :utc_datetime

    belongs_to :user, User
    has_one :notification_comment_at, NotificationCommentAt
    has_one :notification_comment_comment, NotificationCommentComment
    has_one :notification_comment_reaction, NotificationCommentReaction
    has_one :notification_follow, NotificationFollow
    has_one :notification_moderation_request, NotificationModerationRequest
    has_one :notification_moderation_resolution, NotificationModerationResolution
    has_one :notification_private_grant, NotificationPrivateGrant
    has_one :notification_private_request, NotificationPrivateRequest
    has_one :notification_timeline_item_at, NotificationTimelineItemAt
    has_one :notification_timeline_item_comment, NotificationTimelineItemComment
    has_one :notification_timeline_item_reaction, NotificationTimelineItemReaction
  end

  @doc false
  def public_update_changeset(%Notification{} = notification, attrs) do
    notification
    |> cast(attrs, [:read, :seen])
    |> validate_required([:read, :seen])
  end

  @doc false
  def private_changeset(%Notification{} = notification, attrs) do
    notification
    |> cast(attrs, [:user_id, :updated_at, :read, :seen])
    |> validate_required([:user_id, :updated_at, :read, :seen])
    |> assoc_constraint(:user)
  end
end
