import Ecto.Query

defmodule ApiWeb.Services.Notifications.NotificationCommentReactionManager do
  alias Api.Notifications.{Notification, NotificationCommentReactionV2}
  alias ApiWeb.Services.Notifications.NotificationManager
  alias Ecto.Multi

  def delete(reaction) do
    Multi.new
    |> Multi.run(:remove_notification_reaction_notifications, fn _ ->
      {amount, notifications} = Api.Repo.delete_all(Notification
        |> join(:inner, [n], nf in assoc(n, :notification_comment_reaction_v2))
        |> where([n, nf], nf.reaction_id == ^reaction.id),
      returning: true)

      {:ok, notifications}
    end)
  end

  def insert(reaction, comment) do
    Multi.new
    |> Multi.append(NotificationManager.insert(:notification_comment_reaction_notification, comment.user_id))
    |> Multi.run(:notification_comment_reaction, fn %{notification_comment_reaction_notification: notification} ->
      Api.Repo.insert(NotificationCommentReactionV2.private_changeset(%NotificationCommentReactionV2{}, %{
        notification_id: notification.id,
        reaction_id: reaction.id
      }))
    end)
  end
end
