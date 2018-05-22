defmodule Api.Notifications.TimelineItemWatcher do
  use Api.Schema
  import Ecto.Changeset
  alias Api.Accounts.User
  alias Api.Notifications.TimelineItemWatcher
  alias Api.Timeline.TimelineItem


  schema "timeline_item_watchers" do
    belongs_to :watcher, User
    belongs_to :watched, TimelineItem
  end

  @doc false
  def public_insert_changeset(%TimelineItemWatcher{} = timeline_item_watcher, attrs) do
    timeline_item_watcher
    |> cast(attrs, [:watcher_id, :watched_id])
    |> validate_required([:watcher_id, :watched_id])
    |> unique_constraint(:watcher_id, name: :timeline_item_watchers_watched_id_watcher_id_index, message: "remote.errors.detail.unique.follow")
    |> assoc_constraint(:watcher)
    |> assoc_constraint(:watched)
  end
end
