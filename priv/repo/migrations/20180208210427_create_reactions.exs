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
    create constraint(:reactions, :only_one_reactable, check: "count_not_nulls(comment_id, post_id) = 1")
  end
end
