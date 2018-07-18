import Ecto.Query

defmodule ApiWeb.Services.Notifications.NotificationModerationRequestManager do
  alias Api.Accounts.User
  alias Api.Notifications.{Notification, NotificationModerationRequest}
  alias ApiWeb.Services.Notifications.NotificationManager
  alias Ecto.Multi

  def update_and_insert() do
    Multi.new
    |> Multi.update_all(:update_all_moderation_request_notifications,
      Notification
      |> join(:inner, [n], nmr in assoc(n, :notification_moderation_request)),
      [set: [
        updated_at: DateTime.utc_now(),
        is_read: false,
        is_seen: false
      ]],
      returning: true
    )
    |> Multi.run(:moderator_ids, fn _ ->
      {:ok, Enum.map(Api.Repo.all(User |> where([u], u.is_moderator == ^true)), fn (user) -> user.id end)}
    end)
    |> Multi.run(:insert_moderation_request_notifications, fn %{moderator_ids: moderator_ids, update_all_moderation_request_notifications: {_, notifications }} ->
      preexisting_moderator_ids = Enum.map(notifications, fn (notification) -> notification.user_id end)
      new_moderator_ids = moderator_ids -- preexisting_moderator_ids
      now = DateTime.utc_now()

      {amount, notifications} = Api.Repo.insert_all(Notification, Enum.map(new_moderator_ids, fn (user_id) ->
        %{user_id: user_id, updated_at: now}
      end), returning: true)

      if (amount == Kernel.length(new_moderator_ids)), do: {:ok, notifications}, else: {:error, notifications}
    end)
    |> Multi.run(:insert_moderation_requests, fn %{insert_moderation_request_notifications: notifications} ->
      now = DateTime.utc_now()

      {amount, _} = Api.Repo.insert_all(NotificationModerationRequest, Enum.map(notifications, fn (notification) ->
        %{notification_id: notification.id}
      end))

      if (amount == Kernel.length(notifications)), do: {:ok, amount}, else: {:error, amount}
    end)
    |> Multi.run(:broadcast_notifications, fn %{moderator_ids: moderator_ids} ->
      NotificationManager.broadcast_notifications(moderator_ids)
      {:ok, %{}}
    end)
  end
end
