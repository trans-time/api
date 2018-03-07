defmodule Api.Repo.Migrations.CreateComments do
  use Ecto.Migration

  def change do
    create table(:comments) do
      add :text, :string
      add :deleted, :boolean, default: false, null: false
      add :deleted_by_moderator, :boolean, default: false, null: false
      add :deleted_with_parent, :boolean, default: false, null: false
      add :ignore_flags, :boolean, default: false, null: false
      add :under_moderation, :boolean, default: false, null: false
      add :comment_count, :integer, default: 0, null: false
      add :moon_count, :integer, default: 0, null: false
      add :star_count, :integer, default: 0, null: false
      add :sun_count, :integer, default: 0, null: false

      add :post_id, references(:posts, on_delete: :nothing)
      add :user_id, references(:users, on_delete: :nothing), null: false
      add :parent_id, references(:comments, on_delete: :nothing)

      timestamps()
    end

    create index(:comments, [:inserted_at])
    create index(:comments, [:post_id], using: :hash)
    create index(:comments, [:parent_id], using: :hash)
    create index(:comments, [:deleted], type: :hash)
    create index(:comments, [:under_moderation], type: :hash)
    create constraint(:comments, :only_one_commentable, check: "count_not_nulls(post_id) = 1")
  end
end
