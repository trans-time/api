import Ecto.Query

defmodule ApiWeb.Services.Notifications.NotificationModerationViolationManager do
  alias Api.Accounts.User
  alias Api.Notifications.{Notification, NotificationModerationViolation}
  alias Ecto.Multi

  def insert(moderation_report, user_id) do
    Multi.new
    |> Multi.insert(:notification_moderation_violation_notification, Notification.private_changeset(%Notification{}, %{
      user_id: user_id,
      updated_at: DateTime.utc_now()
    }))
    |> Multi.run(:notification_moderation_violation, fn %{notification_moderation_violation_notification: notification} ->
      Api.Repo.insert(NotificationModerationViolation.private_changeset(%NotificationModerationViolation{}, %{
        notification_id: notification.id,
        moderation_report_id: moderation_report.id
      }))
    end)
  end
end
