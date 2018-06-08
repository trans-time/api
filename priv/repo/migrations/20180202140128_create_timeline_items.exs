defmodule Api.Repo.Migrations.CreateTimelineItems do
  use Ecto.Migration

  def change do
    create table(:timeline_items) do
      add :comments_are_locked, :boolean, null: false, default: false
      add :comment_count, :integer, default: 0, null: false
      add :moon_count, :integer, default: 0, null: false
      add :star_count, :integer, default: 0, null: false
      add :sun_count, :integer, default: 0, null: false
      add :reaction_count, :integer, default: 0, null: false
      add :date, :utc_datetime, null: false
      add :is_marked_for_deletion, :boolean, default: false, null: false
      add :is_marked_for_deletion_by_user, :boolean, default: false, null: false
      add :is_marked_for_deletion_by_moderator, :boolean, default: false, null: false
      add :marked_for_deletion_on, :utc_datetime
      add :is_ignoring_flags, :boolean, default: false, null: false
      add :maturity_rating, :integer, default: 0, null: false
      add :is_private, :boolean, default: false, null: false
      add :is_under_moderation, :boolean, default: false, null: false
      add :user_id, references(:users, on_delete: :delete_all), null: false

      timestamps()
    end


    create index(:timeline_items, [:comments_are_locked], using: :hash)
    create index(:timeline_items, [:is_marked_for_deletion], type: :hash)
    create index(:timeline_items, [:marked_for_deletion_on], type: :hash)
    create index(:timeline_items, [:is_private], type: :hash)
    create index(:timeline_items, [:is_under_moderation], type: :hash)
    create index(:timeline_items, [:user_id], type: :hash)
    create index(:timeline_items, ["date DESC"])
    create index(:timeline_items, ["comment_count DESC"])
    create index(:timeline_items, ["moon_count DESC"])
    create index(:timeline_items, ["star_count DESC"])
    create index(:timeline_items, ["sun_count DESC"])
    create index(:timeline_items, ["reaction_count DESC"])
  end
end
