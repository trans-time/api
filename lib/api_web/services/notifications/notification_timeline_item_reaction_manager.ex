import Ecto.Query

defmodule ApiWeb.Services.Notifications.NotificationTimelineItemReactionManager do
  alias Api.Notifications.NotificationTimelineItemReaction
  alias ApiWeb.Services.Notifications.NotificationManager
  alias Ecto.Multi

  def insert(timeline_item) do
    insert_from_reactable(timeline_item)
  end

  defp insert_from_reactable(timeline_item) do
    insert_or_update(timeline_item, Api.Repo.one(NotificationTimelineItemReaction
      |> where([nc], nc.timeline_item_id == ^timeline_item.id)
      |> join(:inner, [nc], n in assoc(nc, :notification))
      |> preload([nc, n], [notification: n])
    ))
  end

  defp insert_or_update(_, %NotificationTimelineItemReaction{} = ntir) do
    NotificationManager.update(:notification_timeline_item_reaction_notification, ntir.notification)
  end

  defp insert_or_update(timeline_item, _) do
    Multi.new
    |> Multi.append(NotificationManager.insert(:notification_timeline_item_reaction_notification, timeline_item.user_id))
    |> Multi.run(:notification_timeline_item_reaction, fn %{notification_timeline_item_reaction_notification: notification} ->
      Api.Repo.insert(NotificationTimelineItemReaction.private_changeset(%NotificationTimelineItemReaction{}, %{
        notification_id: notification.id,
        timeline_item_id: timeline_item.id
      }))
    end)
  end
end
