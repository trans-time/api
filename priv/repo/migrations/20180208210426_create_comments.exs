defmodule Api.Repo.Migrations.CreateComments do
  use Ecto.Migration

  def change do
    create table(:comments) do
      add :text, :string
      add :deleted, :boolean, default: false, null: false
      add :post_id, references(:posts, on_delete: :nothing)
      add :user_id, references(:users, on_delete: :nothing)
      add :parent_id, references(:comments, on_delete: :nothing)

      timestamps()
    end

    create index(:comments, [:post_id])
  end
end
