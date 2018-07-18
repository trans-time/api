import Ecto.Query

defmodule ApiWeb.Services.Notifications.NotificationTimelineItemCommentManager do
  alias Api.Accounts.User
  alias Api.Timeline.Comment
  alias Api.Notifications.{Notification, NotificationTimelineItemComment}
  alias ApiWeb.Services.Notifications.NotificationManager
  alias Ecto.Multi

  def delete(comment) do
    Multi.new
    |> Multi.run(:remove_notification_timeline_item_comment_notifications, fn _ ->
      {amount, notifications} = Api.Repo.delete_all(Notification
        |> join(:inner, [n], nc in assoc(n, :notification_timeline_item_comment))
        |> where([n, nc], nc.comment_id == ^comment.id),
      returning: true)

      {:ok, notifications}
    end)
  end

  def insert(comment) do
    comment = Api.Repo.preload(comment, [timeline_item: [:watchers]])
    watchers = Enum.filter(comment.timeline_item.watchers, fn (watcher) -> watcher.id != comment.user_id end)

    insert_all_from_users(watchers, comment)
  end

  defp insert_all_from_users(users, comment) do
    Multi.new
    |> Multi.run(:notification_timeline_item_comment_user_ids, fn %{
      notification_comment_at_user_ids: notification_comment_at_user_ids,
      notification_comment_comment_user_ids: notification_comment_comment_user_ids
    } ->
      {:ok, Enum.map(users, fn (user) -> user.id end) -- (notification_comment_at_user_ids ++ notification_comment_comment_user_ids)}
    end)
    |> Multi.merge(fn %{notification_timeline_item_comment_user_ids: notification_timeline_item_comment_user_ids} ->
      NotificationManager.insert_all(:notification_timeline_item_comment_notifications, notification_timeline_item_comment_user_ids)
    end)
    |> Multi.run(:notification_timeline_item_comments, fn %{notification_timeline_item_comment_notifications: {_, notifications}} ->
      {amount, _} = Api.Repo.insert_all(NotificationTimelineItemComment, Enum.map(notifications, fn (notification) ->
        %{comment_id: comment.id, notification_id: notification.id}
      end))

      if (amount == Kernel.length(notifications)), do: {:ok, amount}, else: {:error, amount}
    end)
  end
end
