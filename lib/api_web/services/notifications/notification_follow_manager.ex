import Ecto.Query

defmodule ApiWeb.Services.Notifications.NotificationFollowManager do
  alias Api.Accounts.User
  alias Api.Timeline.Comment
  alias Api.Notifications.{Notification, NotificationFollow}
  alias Ecto.Multi

  def delete(follow) do
    Multi.new
    |> Multi.run(:remove_notification_follow_notifications, fn _ ->
      {amount, notifications} = Api.Repo.delete_all(Notification
        |> join(:inner, [n], nf in assoc(n, :notification_follow))
        |> where([n, nf], nf.follow_id == ^follow.id),
      returning: true)

      {:ok, notifications}
    end)
  end

  def insert(follow) do
    Multi.new
    |> Multi.insert(:notification_follow_notification, Notification.private_changeset(%Notification{}, %{
      user_id: follow.followed_id,
      updated_at: DateTime.utc_now()
    }))
    |> Multi.run(:notification_follow, fn %{notification_follow_notification: notification} ->
      Api.Repo.insert(NotificationFollow.private_changeset(%NotificationFollow{}, %{
        notification_id: notification.id,
        follow_id: follow.id
      }))
    end)
  end
end
