import Ecto.Query

defmodule ApiWeb.Services.TimelineItemWatchManager do
  alias Api.Notifications.TimelineItemWatcher
  alias Ecto.Multi

  def delete(record) do
    Multi.new
    |> Multi.delete(:timeline_item_watch, record)
  end

  def insert(timeline_item, user) do
    insert_if_new(Api.Repo.get_by(TimelineItemWatcher, %{
      watcher_id: user.id,
      watched_id: timeline_item.id
    }), timeline_item, user)
  end

  defp insert_if_new(%TimelineItemWatcher{} = _, _, _), do: Multi.new

  defp insert_if_new(_, timeline_item, user) do
    changeset = TimelineItemWatcher.public_insert_changeset(%TimelineItemWatcher{}, %{
      watcher_id: user.id,
      watched_id: timeline_item.id
    })

    Multi.new
    |> Multi.insert(:timeline_item_watch, changeset)
  end
end
