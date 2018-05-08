defmodule Api.Repo.Migrations.CreateComments do
  use Ecto.Migration

  def change do
    create table(:comments) do
      add :text, :text
      add :ignore_flags, :boolean, default: false, null: false
      add :deleted, :boolean, default: false, null: false
      add :deleted_by_moderator, :boolean, default: false, null: false
      add :deleted_by_user, :boolean, default: false, null: false
      add :deleted_with_parent, :boolean, default: false, null: false
      add :deleted_at, :utc_datetime
      add :under_moderation, :boolean, default: false, null: false
      add :comment_count, :integer, default: 0, null: false
      add :moon_count, :integer, default: 0, null: false
      add :star_count, :integer, default: 0, null: false
      add :sun_count, :integer, default: 0, null: false

      add :timeline_item_id, references(:timeline_items, on_delete: :nothing)
      add :user_id, references(:users, on_delete: :nothing), null: false
      add :parent_id, references(:comments, on_delete: :nothing)

      timestamps()
    end

    create index(:comments, [:inserted_at])
    create index(:comments, [:timeline_item_id], using: :hash)
    create index(:comments, [:parent_id], using: :hash)
    create index(:comments, [:deleted], type: :hash)
    create index(:comments, [:deleted_at], type: :hash)
    create index(:comments, [:deleted_with_parent], type: :hash)
    create index(:comments, [:deleted_by_user], type: :hash)
    create index(:comments, [:deleted_by_moderator], type: :hash)
    create index(:comments, [:under_moderation], type: :hash)
    create constraint(:comments, :only_one_commentable, check: "count_not_nulls(timeline_item_id) = 1")
  end
end
