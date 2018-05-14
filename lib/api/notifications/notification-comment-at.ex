defmodule Api.Notifications.NotificationCommentAt do
  use Api.Schema
  import Ecto.Changeset
  alias Api.Timeline.Comment
  alias Api.Notifications.{NotificationCommentAt, Notification}


  schema "notification_comment_ats" do
    belongs_to :comment, Comment
    belongs_to :notification, Notification

    timestamps()
  end

  @doc false
  def private_changeset(%NotificationCommentAt{} = notification_comment_at, attrs) do
    notification_comment_at
    |> cast(attrs, [:comment_id, :notification_id])
    |> validate_required([:comment_id, :notification_id])
    |> assoc_constraint(:comment)
    |> assoc_constraint(:notification)
  end
end
