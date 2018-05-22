import Ecto.Query

defmodule ApiWeb.Services.Notifications.NotificationCommentAtManager do
  alias Api.Accounts.User
  alias Api.Notifications.{Notification, NotificationCommentAt}
  alias Ecto.Multi

  def delete_all(comment) do
    users = Api.Repo.all(from u in User, where: u.username in ^Utils.TextScanner.gather_tags('@', comment.text))

    delete_all_from_users(comment, users)
  end

  def insert_all(comment) do
    users = Api.Repo.all(from u in User, where: u.username in ^Utils.TextScanner.gather_tags('@', comment.text))

    insert_all_from_users(comment, users)
  end

  def insert_added_delete_removed(comment, previous_text, current_text) do
    previous_usernames = Utils.TextScanner.gather_tags('@', previous_text)
    current_usernames = Utils.TextScanner.gather_tags('@', current_text)
    added_usernames = current_usernames -- previous_usernames
    removed_usernames = previous_usernames -- current_usernames
    added_users = Api.Repo.all(from u in User, where: u.username in ^added_usernames)
    removed_users = Api.Repo.all(from u in User, where: u.username in ^removed_usernames)

    Multi.append(insert_all_from_users(comment, added_users), delete_all_from_users(comment, removed_users))
  end

  defp delete_all_from_users(comment, users) do
    Multi.new
    |> Multi.run(:remove_notification_comment_at_notifications, fn _ ->
      {amount, notifications} = Api.Repo.delete_all(Notification
        |> where([n], n.user_id in ^Enum.map(users, fn (user) -> user.id end))
        |> join(:inner, [n], nca in assoc(n, :notification_comment_at))
        |> where([n, nca], nca.comment_id == ^comment.id),
      returning: true)

      if (amount == Kernel.length(users)), do: {:ok, notifications}, else: {:error, notifications}
    end)
  end

  defp insert_all_from_users(comment, users) do
    Multi.new
    |> Multi.run(:notification_comment_at_notifications, fn _ ->
      now = DateTime.utc_now()

      {amount, notifications} = Api.Repo.insert_all(Notification, Enum.map(users, fn (user) ->
        %{user_id: user.id, inserted_at: now, updated_at: now}
      end), returning: true)

      if (amount == Kernel.length(users)), do: {:ok, notifications}, else: {:error, notifications}
    end)
    |> Multi.run(:notification_comment_ats, fn %{notification_comment_at_notifications: notifications} ->
      now = DateTime.utc_now()

      {amount, _} = Api.Repo.insert_all(NotificationCommentAt, Enum.map(notifications, fn (notification) ->
        %{comment_id: comment.id, notification_id: notification.id, inserted_at: now, updated_at: now}
      end))

      if (amount == Kernel.length(notifications)), do: {:ok, amount}, else: {:error, amount}
    end)
  end
end
