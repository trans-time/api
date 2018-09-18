import Ecto.Query

defmodule ApiWeb.Services.Notifications.NotificationTimelineItemReactionManager do
  alias Api.Notifications.{Notification, NotificationTimelineItemReactionV2}
  alias ApiWeb.Services.Notifications.NotificationManager
  alias Ecto.Multi

  def delete(reaction) do
    Multi.new
    |> Multi.run(:remove_notification_reaction_notifications, fn _ ->
      {amount, notifications} = Api.Repo.delete_all(Notification
        |> join(:inner, [n], nf in assoc(n, :notification_timeline_item_reaction_v2))
        |> where([n, nf], nf.reaction_id == ^reaction.id),
      returning: true)

      {:ok, notifications}
    end)
  end

  def insert(reaction, timeline_item) do
    Multi.new
    |> Multi.append(NotificationManager.insert(:notification_timeline_item_reaction_notification, timeline_item.user_id))
    |> Multi.run(:notification_timeline_item_reaction, fn %{notification_timeline_item_reaction_notification: notification} ->
      Api.Repo.insert(NotificationTimelineItemReactionV2.private_changeset(%NotificationTimelineItemReactionV2{}, %{
        notification_id: notification.id,
        reaction_id: reaction.id
      }))
    end)
  end
end
