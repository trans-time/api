import Ecto.Query

defmodule ApiWeb.Services.Notifications.NotificationTimelineItemReactionManager do
  alias Api.Notifications.{Notification, NotificationTimelineItemReaction}
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
    changeset = Notification.private_changeset(ntir.notification, %{
      updated_at: DateTime.utc_now(),
      read: false,
      seen: false
    })

    Multi.new
    |> Multi.update(:notification_timeline_item_reaction_notification, changeset)
  end

  defp insert_or_update(timeline_item, _) do
    Multi.new
    |> Multi.insert(:notification_timeline_item_reaction_notification, Notification.private_changeset(%Notification{}, %{
      user_id: timeline_item.user_id,
      updated_at: DateTime.utc_now()
    }))
    |> Multi.run(:notification_timeline_item_reaction, fn %{notification_timeline_item_reaction_notification: notification} ->
      Api.Repo.insert(NotificationTimelineItemReaction.private_changeset(%NotificationTimelineItemReaction{}, %{
        notification_id: notification.id,
        timeline_item_id: timeline_item.id
      }))
    end)
  end
end
