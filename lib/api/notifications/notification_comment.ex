defmodule Api.Notifications.NotificationComment do
  use Api.Schema
  import Ecto.Changeset
  alias Api.Timeline.TimelineItem
  alias Api.Notifications.{NotificationComment, Notification}


  schema "notification_comments" do
    field :commenter_count, :integer, default: 0

    belongs_to :timeline_item, TimelineItem
    belongs_to :notification, Notification

    timestamps()
  end

  @doc false
  def private_changeset(%NotificationComment{} = notification_comment, attrs) do
    notification_comment
    |> cast(attrs, [:commenter_count, :timeline_item_id, :notification_id])
    |> validate_required([:commenter_count, :timeline_item_id, :notification_id])
    |> assoc_constraint(:timeline_item)
    |> assoc_constraint(:notification)
  end
end
