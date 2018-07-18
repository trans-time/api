import Ecto.Query

defmodule ApiWeb.Services.Notifications.NotificationPrivateRequestManager do
  alias Api.Notifications.{Notification, NotificationPrivateRequest}
  alias ApiWeb.Services.Notifications.NotificationManager
  alias Ecto.Multi

  def insert(follow) do
    if (follow.has_requested_private) do
      insert_or_update(follow, Api.Repo.one(NotificationPrivateRequest
        |> join(:inner, [npr], n in assoc(npr, :notification))
        |> where([npr, n], n.user_id == ^follow.followed_id)
        |> preload([npr, n], [notification: n])
      ))
    else
      Multi.new
    end
  end

  defp insert_or_update(_, %NotificationPrivateRequest{} = npr) do
    NotificationManager.update(:notification_private_request_notification, npr.notification)
  end

  defp insert_or_update(follow, _) do
    Multi.new
    |> Multi.append(NotificationManager.insert(:notification_private_request_notification, follow.followed_id))
    |> Multi.run(:notification_private_request, fn %{notification_private_request_notification: notification} ->
      Api.Repo.insert(NotificationPrivateRequest.private_changeset(%NotificationPrivateRequest{}, %{
        notification_id: notification.id
      }))
    end)
  end
end
