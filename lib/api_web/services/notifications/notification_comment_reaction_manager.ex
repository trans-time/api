import Ecto.Query

defmodule ApiWeb.Services.Notifications.NotificationCommentReactionManager do
  alias Api.Notifications.{Notification, NotificationCommentReaction}
  alias ApiWeb.Services.Notifications.NotificationManager
  alias Ecto.Multi

  def insert(comment) do
    insert_from_reactable(comment)
  end

  defp insert_from_reactable(comment) do
    insert_or_update(comment, Api.Repo.one(NotificationCommentReaction
      |> where([nc], nc.comment_id == ^comment.id)
      |> join(:inner, [nc], n in assoc(nc, :notification))
      |> preload([nc, n], [notification: n])
    ))
  end

  defp insert_or_update(_, %NotificationCommentReaction{} = ncr) do
    NotificationManager.update(:notification_comment_reaction_notification, ncr.notification)
  end

  defp insert_or_update(comment, _) do
    Multi.new
    |> Multi.append(NotificationManager.insert(:notification_comment_reaction_notification, comment.user_id))
    |> Multi.run(:notification_comment_reaction, fn %{notification_comment_reaction_notification: notification} ->
      Api.Repo.insert(NotificationCommentReaction.private_changeset(%NotificationCommentReaction{}, %{
        notification_id: notification.id,
        comment_id: comment.id
      }))
    end)
  end
end
