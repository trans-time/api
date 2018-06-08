defmodule Api.Notifications.NotificationCommentComment do
  use Api.Schema
  import Ecto.Changeset
  alias Api.Timeline.Comment
  alias Api.Notifications.{NotificationCommentComment, Notification}


  schema "notification_comment_comments" do
    belongs_to :comment, Comment
    belongs_to :notification, Notification
  end

  @doc false
  def private_changeset(%NotificationCommentComment{} = notification_comment_comment, attrs) do
    notification_comment_comment
    |> cast(attrs, [:comment_id, :notification_id])
    |> validate_required([:comment_id, :notification_id])
    |> assoc_constraint(:comment)
    |> assoc_constraint(:notification)
  end
end
