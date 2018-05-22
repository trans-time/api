defmodule Api.Repo.Migrations.CreateTimelineItemWatchers do
  use Ecto.Migration

  def change do
    create table(:timeline_item_watchers) do
      add :watcher_id, references(:users, on_delete: :delete_all), null: false
      add :watched_id, references(:timeline_items, on_delete: :delete_all), null: false
    end

    create unique_index(:timeline_item_watchers, [:watched_id, :watcher_id])
  end
end
