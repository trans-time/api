defmodule Api.Repo.Migrations.CreateReactions do
  use Ecto.Migration

  def change do
    create table(:reactions) do
      add :reaction_type, :integer, null: false
      add :comment_id, references(:comments, on_delete: :nothing)
      add :post_id, references(:posts, on_delete: :nothing)
      add :user_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    create index(:reactions, [:comment_id, :post_id])
  end
end
