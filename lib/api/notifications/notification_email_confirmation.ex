defmodule Api.Notifications.NotificationEmailConfirmation do
  use Api.Schema
  import Ecto.Changeset
  alias Api.Notifications.{NotificationEmailConfirmation, Notification}


  schema "notification_email_confirmations" do
    belongs_to :notification, Notification
  end

  @doc false
  def private_changeset(%NotificationEmailConfirmation{} = notification_email_confirmation, attrs) do
    notification_email_confirmation
    |> cast(attrs, [:notification_id])
    |> validate_required([:notification_id])
    |> assoc_constraint(:notification)
  end
end
