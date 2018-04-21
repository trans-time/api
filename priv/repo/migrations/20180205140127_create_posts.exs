defmodule Api.Repo.Migrations.CreatePosts do
  use Ecto.Migration

  def change do
    create table(:posts) do
      add :ignore_flags, :boolean, default: false, null: false
      add :deleted, :boolean, default: false, null: false
      add :deleted_by_user, :boolean, default: false, null: false
      add :deleted_by_moderator, :boolean, default: false, null: false
      add :comments_are_locked, :boolean, null: false, default: false
      add :under_moderation, :boolean, default: false, null: false
      add :nsfw, :boolean, default: false, null: false
      add :text, :text
      add :comment_count, :integer, default: 0, null: false
      add :moon_count, :integer, default: 0, null: false
      add :star_count, :integer, default: 0, null: false
      add :sun_count, :integer, default: 0, null: false

      timestamps()
    end

    alter table("timeline_items") do
      add :post_id, references(:posts)
    end
    create constraint(:timeline_items, :only_one_timelineable, check: "count_not_nulls(post_id) = 1")
    create index(:timeline_items, [:post_id], using: :hash)

    create index(:posts, [:comments_are_locked], using: :hash)
  end
end
