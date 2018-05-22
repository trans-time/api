import Ecto.Query

defmodule ApiWeb.Services.Notifications.NotificationCommentManager do
  alias Api.Accounts.User
  alias Api.Notifications.{Notification, NotificationComment}
  alias Ecto.Multi

  def delete(comment) do
    delete_all_from_users(comment.timeline_item)
  end

  defp delete_all_from_users(timeline_item) do
    notification_comments = Api.Repo.all(NotificationComment
      |> where([nc], nc.timeline_item_id == ^timeline_item.id)
      |> join(:inner, [nc], n in assoc(nc, :notification))
      |> preload([nc, n], [notification: n])
    )

    if (!Enum.empty?(notification_comments) && notification_comments[0].comment_count <= 1) do
      Multi.new
      |> Multi.run(:remove_notification_comment_notifications, fn _ ->
        {amount, notifications} = Api.Repo.delete_all(Notification
          |> where([n], n.id in ^Enum.map(notification_comments, fn (nc) -> nc.notification_id end))
          |> join(:inner, [n], ntia in assoc(n, :notification_timeline_item_at)),
          returning: true
        )

        if (amount == Kernel.length(notification_comments)), do: {:ok, notifications}, else: {:error, notifications}
      end)
    else
      now = DateTime.utc_now()

      {amount, _} = Api.Repo.update_all(
        NotificationComment
        |> where([nc], nc.id in ^Enum.map(notification_comments, fn (nc) -> nc.id end)),
        inc: [comment_count: -1],
        returning: true
      )

      if (amount == Kernel.length(notification_comments)), do: {:ok, amount}, else: {:error, amount}
    end
  end

  def insert(comment) do
    comment = Api.Repo.preload(comment, [timeline_item: [:watchers]])
    watchers = Enum.filter(comment.timeline_item.watchers, fn (watcher) -> watcher.id != comment.user_id end)

    insert_all_from_users(watchers, comment.timeline_item)
  end

  defp insert_all_from_users(users, timeline_item) do
    all_user_ids = Enum.map(users, fn (user) -> user.id end)
    preexisting_notification_comments = Api.Repo.all(NotificationComment
      |> where([nc], nc.timeline_item_id == ^timeline_item.id)
      |> join(:inner, [nc], n in assoc(nc, :notification))
      |> where([nc, n], n.user_id in ^all_user_ids)
      |> preload([nc, n], [notification: n])
    )
    preexisting_user_ids = Enum.map(preexisting_notification_comments, fn (nc) -> nc.notification.user_id end)
    new_user_ids = all_user_ids -- preexisting_user_ids
    Multi.new
    |> Multi.run(:new_notification_comment_notifications, fn _ ->
      now = DateTime.utc_now()

      {amount, notifications} = Api.Repo.insert_all(Notification, Enum.map(new_user_ids, fn (user_id) ->
        %{user_id: user_id, inserted_at: now, updated_at: now}
      end), returning: true)

      if (amount == Kernel.length(new_user_ids)), do: {:ok, notifications}, else: {:error, notifications}
    end)
    |> Multi.run(:new_notification_comments, fn %{new_notification_comment_notifications: notifications} ->
      now = DateTime.utc_now()

      {amount, _} = Api.Repo.insert_all(NotificationComment, Enum.map(notifications, fn (notification) ->
        %{timeline_item_id: timeline_item.id, notification_id: notification.id, inserted_at: now, updated_at: now, comment_count: 1}
      end))

      if (amount == Kernel.length(notifications)), do: {:ok, amount}, else: {:error, amount}
    end)
    |> Multi.run(:preexisting_notification_comment_notifications, fn _ ->
      now = DateTime.utc_now()

      {amount, notifications} = Api.Repo.update_all(
        Notification
        |> where([n], n.id in ^Enum.map(preexisting_notification_comments, fn (nc) -> nc.notification.id end)),
        [set: [seen: false, read: false, updated_at: now]],
        returning: true
      )

      if (amount == Kernel.length(preexisting_notification_comments)), do: {:ok, notifications}, else: {:error, notifications}
    end)
    |> Multi.run(:preexisting_notification_comments, fn %{preexisting_notification_comment_notifications: notifications} ->
      {amount, _} = Api.Repo.update_all(
        NotificationComment
        |> where([nc], nc.notification_id in ^Enum.map(notifications, fn (n) -> n.id end)),
        [inc: [comment_count: 1]],
        returning: true
      )

      if (amount == Kernel.length(notifications)), do: {:ok, amount}, else: {:error, amount}
    end)
  end
end
