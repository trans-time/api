import Ecto.Query

defmodule ApiWeb.Services.Notifications.NotificationManager do
  alias Api.Accounts.User
  alias Api.Timeline.{Comment, TimelineItem}
  alias Api.Notifications.{Notification, NotificationCommentAt}
  alias Ecto.Multi

  def remove_from_moderation(%Comment{} = comment) do
    notification_types = [:notification_comment_ats]
    comment = Api.Repo.preload(comment, Enum.map(notification_types, fn (type) -> {type, [:notification]} end))
    notifications = List.flatten(Enum.map(notification_types, fn (type) -> Enum.map(Map.get(comment, type), fn (nca) -> nca.notification end) end))
    notification_ids = Enum.map(notifications, fn (notification) -> notification.id end)

    Multi.new
    |> Multi.update_all(:remove_notification_from_moderation, from(n in Notification, where: n.id in ^notification_ids), set: [under_moderation: false])
  end

  def remove_from_moderation(%TimelineItem{} = timeline_item) do
    notification_types = [:notification_timeline_item_ats]
    timeline_item = Api.Repo.preload(timeline_item, Enum.map(notification_types, fn (type) -> {type, [:notification]} end))
    notifications = List.flatten(Enum.map(notification_types, fn (type) -> Enum.map(Map.get(timeline_item, type), fn (nca) -> nca.notification end) end))
    notification_ids = Enum.map(notifications, fn (notification) -> notification.id end)

    Multi.new
    |> Multi.update_all(:remove_notification_from_moderation, from(n in Notification, where: n.id in ^notification_ids), set: [under_moderation: false])
  end
end
