defmodule Api.Repo.Migrations.CreateReactions do
  use Ecto.Migration

  def change do
    create table(:posts_reactions) do
      add :type, :integer, null: false
      add :reactable_id, references(:posts, on_delete: :nothing)
      add :user_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    create index(:posts_reactions, [:reactable_id])
    create index(:posts_reactions, [:user_id])
  end
end
