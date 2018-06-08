defmodule Api.Notifications.NotificationModerationRequest do
  use Api.Schema
  import Ecto.Changeset
  alias Api.Relationship.ModerationRequest
  alias Api.Notifications.{NotificationModerationRequest, Notification}


  schema "notification_moderation_requests" do
    belongs_to :notification, Notification
  end

  @doc false
  def private_changeset(%NotificationModerationRequest{} = notification_moderation_request, attrs) do
    notification_moderation_request
    |> cast(attrs, [:notification_id])
    |> validate_required([:notification_id])
    |> assoc_constraint(:notification)
  end
end
