defmodule Api.Repo.Migrations.CreateComments do
  use Ecto.Migration

  def change do
    create table(:comments) do
      add :text, :text
      add :is_ignoring_flags, :boolean, default: false, null: false
      add :is_marked_for_deletion, :boolean, default: false, null: false
      add :is_marked_for_deletion_by_moderator, :boolean, default: false, null: false
      add :is_marked_for_deletion_by_user, :boolean, default: false, null: false
      add :is_marked_for_deletion_with_parent, :boolean, default: false, null: false
      add :marked_for_deletion_on, :utc_datetime
      add :is_under_moderation, :boolean, default: false, null: false
      add :comment_count, :integer, default: 0, null: false
      add :moon_count, :integer, default: 0, null: false
      add :star_count, :integer, default: 0, null: false
      add :sun_count, :integer, default: 0, null: false
      add :reaction_count, :integer, default: 0, null: false

      add :timeline_item_id, references(:timeline_items, on_delete: :delete_all), null: false
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :parent_id, references(:comments, on_delete: :delete_all)

      timestamps()
    end

    create index(:comments, [:inserted_at])
    create index(:comments, [:timeline_item_id], using: :hash)
    create index(:comments, [:parent_id], using: :hash)
    create index(:comments, [:is_marked_for_deletion], type: :hash)
    create index(:comments, [:marked_for_deletion_on], type: :hash)
    create index(:comments, [:is_marked_for_deletion_with_parent], type: :hash)
    create index(:comments, [:is_marked_for_deletion_by_user], type: :hash)
    create index(:comments, [:is_marked_for_deletion_by_moderator], type: :hash)
    create index(:comments, [:is_under_moderation], type: :hash)
    create constraint(:comments, :only_one_commentable, check: "count_not_nulls(timeline_item_id) = 1")
  end
end
