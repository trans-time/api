import Ecto.Query

defmodule ApiWeb.Services.CommentWatchManager do
  alias Api.Notifications.CommentWatcher
  alias Api.Timeline.Comment
  alias Ecto.Multi

  def delete(record) do
    Multi.new
    |> Multi.delete(:comment_watch, record)
  end

  def insert(%Comment{} = comment, user) do
    IO.inspect(comment)
    insert_if_new(Api.Repo.get_by(CommentWatcher, %{
      watcher_id: user.id,
      watched_id: comment.id
    }), comment, user)
  end

  defp insert_if_new(%CommentWatcher{} = _, _, _), do: Multi.new

  defp insert_if_new(_, comment, user) do
    changeset = CommentWatcher.public_insert_changeset(%CommentWatcher{}, %{
      watcher_id: user.id,
      watched_id: comment.id
    })

    Multi.new
    |> Multi.insert(:comment_watch, changeset)
  end
end
