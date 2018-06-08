import Ecto.Query

defmodule ApiWeb.Services.Notifications.NotificationModerationResolutionManager do
  alias Api.Accounts.User
  alias Api.Notifications.{Notification, NotificationModerationResolution}
  alias Ecto.Multi

  # def delete_all(verdict) do
  #   verdict = Api.Repo.preload(verdict, moderation_report: [:flags])
  #   user_ids = Enum.map(verdict.moderation_report.flags, fn (flag) -> flag.user_id end)
  #
  #   delete_all_from_users(verdict, user_ids)
  # end

  def insert_all(verdict) do
    verdict = Api.Repo.preload(verdict, moderation_report: [flags: [:user]])
    user_ids = Enum.map(verdict.moderation_report.flags, fn (flag) -> flag.user_id end)

    insert_all_from_users(verdict, user_ids)
  end

  # defp delete_all_from_users(verdict, user_ids) do
  #   Multi.new
  #   |> Multi.run(:remove_notification_moderation_resolution_notifications, fn _ ->
  #     {amount, notifications} = Api.Repo.delete_all(Notification
  #       |> where([n], n.user_id in ^user_ids)
  #       |> join(:inner, [n], nmr in assoc(n, :notification_moderation_resolution))
  #       |> where([n, nmr], nmr.flag_id in ^Enum.map(verdict.moderation_report.flags, fn (flag) -> flag.id end)),
  #     returning: true)
  #
  #     if (amount == Kernel.length(users)), do: {:ok, notifications}, else: {:error, notifications}
  #   end)
  # end

  defp insert_all_from_users(verdict, user_ids) do
    Multi.new
    |> Multi.run(:notification_moderation_resolution_notifications, fn _ ->
      now = DateTime.utc_now()

      {amount, notifications} = Api.Repo.insert_all(Notification, Enum.map(user_ids, fn (user_id) ->
        %{user_id: user_id, updated_at: now}
      end), returning: true)

      if (amount == Kernel.length(user_ids)), do: {:ok, notifications}, else: {:error, notifications}
    end)
    |> Multi.run(:notification_moderation_resolutions, fn %{notification_moderation_resolution_notifications: notifications} ->
      now = DateTime.utc_now()

      {amount, _} = Api.Repo.insert_all(NotificationModerationResolution, Enum.map(notifications, fn (notification) ->
        flag = Enum.find(verdict.moderation_report.flags, fn (flag) -> flag.user_id == notification.user_id end)
        %{flag_id: flag.id, notification_id: notification.id}
      end))

      if (amount == Kernel.length(notifications)), do: {:ok, amount}, else: {:error, amount}
    end)
  end
end
