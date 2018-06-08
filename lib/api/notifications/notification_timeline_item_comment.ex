defmodule Api.Notifications.NotificationTimelineItemComment do
  use Api.Schema
  import Ecto.Changeset
  alias Api.Timeline.Comment
  alias Api.Notifications.{NotificationTimelineItemComment, Notification}


  schema "notification_timeline_item_comments" do
    belongs_to :comment, Comment
    belongs_to :notification, Notification
  end

  @doc false
  def private_changeset(%NotificationTimelineItemComment{} = notification_timeline_item_comment, attrs) do
    notification_timeline_item_comment
    |> cast(attrs, [:comment_id, :notification_id])
    |> validate_required([:comment_id, :notification_id])
    |> assoc_constraint(:comment)
    |> assoc_constraint(:notification)
  end
end
