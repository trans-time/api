defmodule Api.Repo.Migrations.CreateTimelineItems do
  use Ecto.Migration

  def change do
    create table(:timeline_items) do
      add :comments_are_locked, :boolean, null: false, default: false
      add :comment_count, :integer, default: 0, null: false
      add :moon_count, :integer, default: 0, null: false
      add :star_count, :integer, default: 0, null: false
      add :sun_count, :integer, default: 0, null: false
      add :date, :utc_datetime, null: false
      add :deleted, :boolean, default: false, null: false
      add :deleted_by_user, :boolean, default: false, null: false
      add :deleted_by_moderator, :boolean, default: false, null: false
      add :deleted_at, :utc_datetime
      add :ignore_flags, :boolean, default: false, null: false
      add :maturity_rating, :integer, default: 0, null: false
      add :private, :boolean, default: false, null: false
      add :under_moderation, :boolean, default: false, null: false
      add :user_id, references(:users), null: false

      timestamps()
    end


    create index(:timeline_items, [:comments_are_locked], using: :hash)
    create index(:timeline_items, ["date DESC"])
    create index(:timeline_items, [:deleted], type: :hash)
    create index(:timeline_items, [:deleted_at], type: :hash)
    create index(:timeline_items, [:private], type: :hash)
    create index(:timeline_items, [:under_moderation], type: :hash)
    create index(:timeline_items, [:user_id], type: :hash)
  end
end
