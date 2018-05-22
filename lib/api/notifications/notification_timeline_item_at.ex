defmodule Api.Notifications.NotificationTimelineItemAt do
  use Api.Schema
  import Ecto.Changeset
  alias Api.Timeline.TimelineItem
  alias Api.Notifications.{NotificationTimelineItemAt, Notification}


  schema "notification_timeline_item_ats" do
    belongs_to :timeline_item, TimelineItem
    belongs_to :notification, Notification

    timestamps()
  end

  @doc false
  def private_changeset(%NotificationTimelineItemAt{} = notification_timeline_item_at, attrs) do
    notification_timeline_item_at
    |> cast(attrs, [:timeline_item_id, :notification_id])
    |> validate_required([:timeline_item_id, :notification_id])
    |> assoc_constraint(:timeline_item)
    |> assoc_constraint(:notification)
  end
end
