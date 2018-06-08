defmodule Api.Notifications.NotificationModerationViolation do
  use Api.Schema
  import Ecto.Changeset
  alias Api.Moderation.ModerationReport
  alias Api.Notifications.{NotificationModerationViolation, Notification}


  schema "notification_moderation_violations" do
    belongs_to :moderation_report, ModerationReport
    belongs_to :notification, Notification
  end

  @doc false
  def private_changeset(%NotificationModerationViolation{} = notification_moderation_violation, attrs) do
    notification_moderation_violation
    |> cast(attrs, [:moderation_report_id, :notification_id])
    |> validate_required([:moderation_report_id, :notification_id])
    |> assoc_constraint(:moderation_report)
    |> assoc_constraint(:notification)
  end
end
