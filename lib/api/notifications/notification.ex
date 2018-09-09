defmodule Api.Notifications.Notification do
  use Api.Schema
  import Ecto.Changeset
  alias Api.Accounts.User
  alias Api.Notifications.{
    Notification,
    NotificationCommentAt,
    NotificationCommentComment,
    NotificationCommentReaction,
    NotificationEmailConfirmation,
    NotificationFollow,
    NotificationModerationRequest,
    NotificationModerationResolution,
    NotificationModerationViolation,
    NotificationPrivateGrant,
    NotificationPrivateRequest,
    NotificationTimelineItemComment,
    NotificationTimelineItemAt,
    NotificationTimelineItemReaction
  }


  schema "notifications" do
    field :is_read, :boolean, default: false
    field :is_seen, :boolean, default: false
    field :updated_at, :utc_datetime

    belongs_to :user, User
    has_one :notification_comment_at, NotificationCommentAt
    has_one :notification_comment_comment, NotificationCommentComment
    has_one :notification_comment_reaction, NotificationCommentReaction
    has_one :notification_email_confirmation, NotificationEmailConfirmation
    has_one :notification_follow, NotificationFollow
    has_one :notification_moderation_request, NotificationModerationRequest
    has_one :notification_moderation_resolution, NotificationModerationResolution
    has_one :notification_moderation_violation, NotificationModerationViolation
    has_one :notification_private_grant, NotificationPrivateGrant
    has_one :notification_private_request, NotificationPrivateRequest
    has_one :notification_timeline_item_at, NotificationTimelineItemAt
    has_one :notification_timeline_item_comment, NotificationTimelineItemComment
    has_one :notification_timeline_item_reaction, NotificationTimelineItemReaction
  end

  @doc false
  def public_update_changeset(%Notification{} = notification, attrs) do
    notification
    |> cast(attrs, [:is_read, :is_seen])
    |> validate_required([:is_read, :is_seen])
  end

  @doc false
  def private_changeset(%Notification{} = notification, attrs) do
    notification
    |> cast(attrs, [:user_id, :updated_at, :is_read, :is_seen])
    |> validate_required([:user_id, :updated_at, :is_read, :is_seen])
    |> assoc_constraint(:user)
  end
end
