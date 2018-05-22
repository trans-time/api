import Ecto.Query

defmodule ApiWeb.Services.Notifications.NotificationManager do
  alias Api.Timeline.{Comment, TimelineItem}
  alias ApiWeb.Services.{CommentManager,PostManager}

  def remove_from_moderation(%Comment{} = comment) do
    CommentManager.insert_notifications(comment)
  end

  def remove_from_moderation(%TimelineItem{} = timeline_item) do
    PostManager.insert_notifications(timeline_item)
  end
end
