defmodule Api.Notifications.NotificationCommentReactionV2 do
  use Api.Schema
  import Ecto.Changeset
  alias Api.Timeline.Reaction
  alias Api.Notifications.{NotificationCommentReactionV2, Notification}


  schema "notification_comment_reaction_v2s" do
    belongs_to :reaction, Reaction
    belongs_to :notification, Notification
  end

  @doc false
  def private_changeset(%NotificationCommentReactionV2{} = notification_comment_reaction, attrs) do
    notification_comment_reaction
    |> cast(attrs, [:reaction_id, :notification_id])
    |> validate_required([:reaction_id, :notification_id])
    |> assoc_constraint(:reaction)
    |> assoc_constraint(:notification)
  end
end
