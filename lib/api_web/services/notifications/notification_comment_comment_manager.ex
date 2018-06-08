import Ecto.Query

defmodule ApiWeb.Services.Notifications.NotificationCommentCommentManager do
  alias Api.Accounts.User
  alias Api.Timeline.Comment
  alias Api.Notifications.{Notification, NotificationCommentComment}
  alias Ecto.Multi

  def delete(comment) do
    Multi.new
    |> Multi.run(:remove_notification_comment_comment_notifications, fn _ ->
      {amount, notifications} = Api.Repo.delete_all(Notification
        |> join(:inner, [n], nc in assoc(n, :notification_comment_comment))
        |> where([n, nc], nc.comment_id == ^comment.id),
      returning: true)

      {:ok, notifications}
    end)
  end

  def insert(comment) do
    comment = Api.Repo.preload(comment, [parent: [:watchers]])
    watchers = if comment.parent, do: comment.parent.watchers, else: []
    watchers = Enum.filter(watchers, fn (watcher) -> watcher.id != comment.user_id end)

    Multi.new
    |> Multi.run(:notification_comment_comment_user_ids, fn %{notification_comment_at_user_ids: notification_comment_at_user_ids} ->
      {:ok, Enum.map(watchers, fn (user) -> user.id end) -- notification_comment_at_user_ids}
    end)
    |> Multi.append(if (comment.parent != nil), do: insert_all_from_users(watchers, comment), else: Multi.new)
  end

  defp insert_all_from_users(users, comment) do
    Multi.new
    |> Multi.run(:notification_comment_comment_notifications, fn %{notification_comment_comment_user_ids: notification_comment_comment_user_ids} ->
      now = DateTime.utc_now()

      {amount, notifications} = Api.Repo.insert_all(Notification, Enum.map(notification_comment_comment_user_ids, fn (user_id) ->
        %{user_id: user_id, updated_at: now}
      end), returning: true)

      if (amount == Kernel.length(notification_comment_comment_user_ids)), do: {:ok, notifications}, else: {:error, notifications}
    end)
    |> Multi.run(:notification_comment_comments, fn %{notification_comment_comment_notifications: notifications} ->
      {amount, _} = Api.Repo.insert_all(NotificationCommentComment, Enum.map(notifications, fn (notification) ->
        %{comment_id: comment.id, notification_id: notification.id}
      end))

      if (amount == Kernel.length(notifications)), do: {:ok, amount}, else: {:error, amount}
    end)
  end
end
