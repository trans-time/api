defmodule Api.Notifications.NotificationModerationResolution do
  use Api.Schema
  import Ecto.Changeset
  alias Api.Moderation.Flag
  alias Api.Notifications.{NotificationModerationResolution, Notification}


  schema "notification_moderation_resolutions" do
    belongs_to :flag, Flag
    belongs_to :notification, Notification
  end

  @doc false
  def private_changeset(%NotificationModerationResolution{} = notification_moderation_resolution, attrs) do
    notification_moderation_resolution
    |> cast(attrs, [:flag_id, :notification_id])
    |> validate_required([:flag_id, :notification_id])
    |> assoc_constraint(:flag)
    |> assoc_constraint(:notification)
  end
end
