import Ecto.Query

defmodule ApiWeb.Services.Notifications.NotificationManager do
  alias Api.Notifications.Notification
  alias Api.Timeline.{Comment, TimelineItem}
  alias ApiWeb.Services.{CommentManager,PostManager}
  alias Ecto.Multi

  def remove_from_moderation(%Comment{} = comment) do
    CommentManager.insert_notifications(comment)
  end

  def remove_from_moderation(%TimelineItem{} = timeline_item) do
    PostManager.insert_notifications(timeline_item)
  end

  def insert_all(name, user_ids) do
    now = DateTime.utc_now()
    Multi.new
    |> Multi.insert_all(name, Notification, Enum.map(user_ids, fn (user_id) ->
      %{user_id: user_id, updated_at: now}
    end), returning: true)
    |> Multi.run("broadcast_notifications_#{DateTime.to_string(now)}", fn _ ->
      broadcast_notifications(user_ids)
      {:ok, %{}}
    end)
  end

  def insert(name, user_id) do
    now = DateTime.utc_now()
    Multi.new
    |> Multi.insert(name, Notification.private_changeset(%Notification{}, %{
      user_id: user_id,
      updated_at: DateTime.utc_now()
    }))
    |> Multi.run("broadcast_notification_#{DateTime.to_string(now)}", fn _ ->
      broadcast_notification(user_id)
      {:ok, %{}}
    end)
  end

  def update(name, notification) do
    now = DateTime.utc_now()
    changeset = Notification.private_changeset(notification, %{
      updated_at: now,
      is_read: false,
      is_seen: false
    })

    Multi.new
    |> Multi.update(name, changeset)
    |> Multi.run("broadcast_notification_#{DateTime.to_string(now)}", fn _ ->
      broadcast_notification(notification.user_id)
      {:ok, %{}}
    end)
  end

  def broadcast_notifications(user_ids) do
    Enum.each(user_ids, &broadcast_notification/1)
  end

  def broadcast_notification(user_id) do
    ApiWeb.Endpoint.broadcast("user:#{user_id}", "new_notification", %{
      unseen_notification_count: Enum.at(Api.Repo.all(from(
        n in Api.Notifications.Notification,
        where: n.user_id == ^user_id and n.is_seen == ^false,
        select: count(n.id)
      )), 0)
    })
  end
end
