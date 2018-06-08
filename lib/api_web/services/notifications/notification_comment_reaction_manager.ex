import Ecto.Query

defmodule ApiWeb.Services.Notifications.NotificationCommentReactionManager do
  alias Api.Notifications.{Notification, NotificationCommentReaction}
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
    changeset = Notification.private_changeset(ncr.notification, %{
      updated_at: DateTime.utc_now(),
      read: false,
      seen: false
    })

    Multi.new
    |> Multi.update(:notification_comment_reaction_notification, changeset)
  end

  defp insert_or_update(comment, _) do
    Multi.new
    |> Multi.insert(:notification_comment_reaction_notification, Notification.private_changeset(%Notification{}, %{
      user_id: comment.user_id,
      updated_at: DateTime.utc_now()
    }))
    |> Multi.run(:notification_comment_reaction, fn %{notification_comment_reaction_notification: notification} ->
      Api.Repo.insert(NotificationCommentReaction.private_changeset(%NotificationCommentReaction{}, %{
        notification_id: notification.id,
        comment_id: comment.id
      }))
    end)
  end
end
