defmodule Api.Notifications.NotificationPrivateRequest do
  use Api.Schema
  import Ecto.Changeset
  alias Api.Notifications.{NotificationPrivateRequest, Notification}


  schema "notification_private_requests" do
    belongs_to :notification, Notification
  end

  @doc false
  def private_changeset(%NotificationPrivateRequest{} = notification_private_request, attrs) do
    notification_private_request
    |> cast(attrs, [:notification_id])
    |> validate_required([:notification_id])
    |> assoc_constraint(:notification)
  end
end
