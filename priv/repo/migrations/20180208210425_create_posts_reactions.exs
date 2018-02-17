defmodule Api.Repo.Migrations.CreatePostsReactions do
  use Ecto.Migration

  def change do
    create table(:posts_reactions) do
      add :type, :integer, null: false
      add :reactable_id, references(:posts, on_delete: :nothing)
      add :user_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    create index(:posts_reactions, [:reactable_id])
  end
end
