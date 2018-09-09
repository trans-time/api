import Ecto.Query

defmodule ApiWeb.Services.Notifications.NotificationEmailConfirmationManager do
  alias Api.Notifications.{Notification, NotificationEmailConfirmation}
  alias ApiWeb.Services.Notifications.NotificationManager
  alias Ecto.Multi

  def insert(user) do
    Multi.new
    |> Multi.append(NotificationManager.insert(:notification_email_confirmation_notification, user.id))
    |> Multi.run(:notification_follow, fn %{notification_email_confirmation_notification: notification} ->
      Api.Repo.insert(NotificationEmailConfirmation.private_changeset(%NotificationEmailConfirmation{}, %{
        notification_id: notification.id
      }))
    end)
  end
end
