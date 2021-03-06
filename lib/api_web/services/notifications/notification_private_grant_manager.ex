import Ecto.Query

defmodule ApiWeb.Services.Notifications.NotificationPrivateGrantManager do
  alias Api.Notifications.{Notification, NotificationPrivateGrant}
  alias ApiWeb.Services.Notifications.NotificationManager
  alias Ecto.Multi

  def insert_or_delete(follow) do
    if follow.can_view_private, do: insert(follow), else: delete(follow)
  end

  defp insert(follow) do
    Multi.new
    |> Multi.append(NotificationManager.insert(:notification_private_grant_notification, follow.follower_id))
    |> Multi.run(:notification_private_grant, fn %{notification_private_grant_notification: notification} ->
      Api.Repo.insert(NotificationPrivateGrant.private_changeset(%NotificationPrivateGrant{}, %{
        notification_id: notification.id,
        follow_id: follow.id
      }))
    end)
  end

  defp delete(follow) do
    Multi.new
    |> Multi.run(:remove_notification_private_grant_notifications, fn _ ->
      {amount, notifications} = Api.Repo.delete_all(Notification
        |> join(:inner, [n], nf in assoc(n, :notification_private_grant))
        |> where([n, nf], nf.follow_id == ^follow.id),
      returning: true)

      {:ok, notifications}
    end)
  end
end
