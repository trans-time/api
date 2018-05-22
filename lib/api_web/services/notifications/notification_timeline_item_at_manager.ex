import Ecto.Query

defmodule ApiWeb.Services.Notifications.NotificationTimelineItemAtManager do
  alias Api.Accounts.User
  alias Api.Notifications.{Notification, NotificationTimelineItemAt}
  alias Ecto.Multi

  def delete_all(timeline_item) do
    users = Api.Repo.all(from u in User, where: u.username in ^Utils.TextScanner.gather_tags('@', timeline_item.post.text))

    delete_all_from_users(timeline_item, users)
  end

  def insert_all(timeline_item) do
    users = Api.Repo.all(from u in User, where: u.username in ^Utils.TextScanner.gather_tags('@', timeline_item.post.text))

    insert_all_from_users(timeline_item, users)
  end

  def insert_added_delete_removed(timeline_item, previous_text, current_text) do
    previous_usernames = Utils.TextScanner.gather_tags('@', previous_text)
    current_usernames = Utils.TextScanner.gather_tags('@', current_text)
    added_usernames = current_usernames -- previous_usernames
    removed_usernames = previous_usernames -- current_usernames
    added_users = Api.Repo.all(from u in User, where: u.username in ^added_usernames)
    removed_users = Api.Repo.all(from u in User, where: u.username in ^removed_usernames)

    Multi.append(insert_all_from_users(timeline_item, added_users), delete_all_from_users(timeline_item, removed_users))
  end

  defp delete_all_from_users(timeline_item, users) do
    Multi.new
    |> Multi.run(:remove_notification_timeline_item_at_notifications, fn _ ->
      {amount, notifications} = Api.Repo.delete_all(Notification
        |> where([n], n.user_id in ^Enum.map(users, fn (user) -> user.id end))
        |> join(:inner, [n], ntia in assoc(n, :notification_timeline_item_at))
        |> where([n, ntia], ntia.timeline_item_id == ^timeline_item.id),
      returning: true)

      if (amount == Kernel.length(users)), do: {:ok, notifications}, else: {:error, notifications}
    end)
  end

  defp insert_all_from_users(timeline_item, users) do
    Multi.new
    |> Multi.run(:notification_timeline_item_at_notifications, fn _ ->
      now = DateTime.utc_now()

      {amount, notifications} = Api.Repo.insert_all(Notification, Enum.map(users, fn (user) ->
        %{user_id: user.id, inserted_at: now, updated_at: now}
      end), returning: true)

      if (amount == Kernel.length(users)), do: {:ok, notifications}, else: {:error, notifications}
    end)
    |> Multi.run(:notification_timeline_item_ats, fn %{notification_timeline_item_at_notifications: notifications} ->
      now = DateTime.utc_now()

      {amount, _} = Api.Repo.insert_all(NotificationTimelineItemAt, Enum.map(notifications, fn (notification) ->
        %{timeline_item_id: timeline_item.id, notification_id: notification.id, inserted_at: now, updated_at: now}
      end))

      if (amount == Kernel.length(notifications)), do: {:ok, amount}, else: {:error, amount}
    end)
  end
end
