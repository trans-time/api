defmodule Api.Repo.Migrations.CreateCommentWatchers do
  use Ecto.Migration

  def change do
    create table(:comment_watchers) do
      add :watcher_id, references(:users, on_delete: :delete_all), null: false
      add :watched_id, references(:comments, on_delete: :delete_all), null: false
    end

    create unique_index(:comment_watchers, [:watched_id, :watcher_id])
  end
end
