defmodule Api.Notifications.CommentWatcher do
  use Api.Schema
  import Ecto.Changeset
  alias Api.Accounts.User
  alias Api.Notifications.CommentWatcher
  alias Api.Timeline.TimelineItem


  schema "comment_watchers" do
    belongs_to :watcher, User
    belongs_to :watched, TimelineItem
  end

  @doc false
  def public_insert_changeset(%CommentWatcher{} = comment_watcher, attrs) do
    comment_watcher
    |> cast(attrs, [:watcher_id, :watched_id])
    |> validate_required([:watcher_id, :watched_id])
    |> unique_constraint(:watcher_id, name: :comment_watchers_watched_id_watcher_id_index, message: "remote.errors.detail.unique.follow")
    |> assoc_constraint(:watcher)
    |> assoc_constraint(:watched)
  end
end
