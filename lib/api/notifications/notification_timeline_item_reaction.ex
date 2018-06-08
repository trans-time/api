defmodule Api.Notifications.NotificationTimelineItemReaction do
  use Api.Schema
  import Ecto.Changeset
  alias Api.Timeline.TimelineItem
  alias Api.Notifications.{NotificationTimelineItemReaction, Notification}


  schema "notification_timeline_item_reactions" do
    belongs_to :timeline_item, TimelineItem
    belongs_to :notification, Notification
  end

  @doc false
  def private_changeset(%NotificationTimelineItemReaction{} = notification_timeline_item_reaction, attrs) do
    notification_timeline_item_reaction
    |> cast(attrs, [:timeline_item_id, :notification_id])
    |> validate_required([:timeline_item_id, :notification_id])
    |> assoc_constraint(:timeline_item)
    |> assoc_constraint(:notification)
  end
end
