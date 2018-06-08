defmodule Api.Notifications.NotificationCommentReaction do
  use Api.Schema
  import Ecto.Changeset
  alias Api.Timeline.Comment
  alias Api.Notifications.{NotificationCommentReaction, Notification}


  schema "notification_comment_reactions" do
    belongs_to :comment, Comment
    belongs_to :notification, Notification
  end

  @doc false
  def private_changeset(%NotificationCommentReaction{} = notification_comment_reaction, attrs) do
    notification_comment_reaction
    |> cast(attrs, [:comment_id, :notification_id])
    |> validate_required([:comment_id, :notification_id])
    |> assoc_constraint(:comment)
    |> assoc_constraint(:notification)
  end
end
