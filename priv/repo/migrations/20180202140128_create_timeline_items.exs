defmodule Api.Repo.Migrations.CreateTimelineItems do
  use Ecto.Migration

  def change do
    create table(:timeline_items) do
      add :comments_locked, :boolean, default: false, null: false
      add :date, :utc_datetime
      add :deleted, :boolean, default: false, null: false
      add :deleted_by_moderator, :boolean, default: false, null: false
      add :ignore_flags, :boolean, default: false, null: false
      add :private, :boolean, default: false, null: false
      add :under_moderation, :boolean, default: false, null: false
      add :user_id, references(:users)

      timestamps()
    end

    create index(:timeline_items, [:date, :deleted, :private, :under_moderation, :user_id])
  end
end
