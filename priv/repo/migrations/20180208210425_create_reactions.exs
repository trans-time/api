defmodule Api.Repo.Migrations.CreateReactions do
  use Ecto.Migration

  def change do
    create table(:reactions) do
      add :type, :integer, null: false
      add :timeline_item_id, references(:timeline_items, on_delete: :nothing)
      add :user_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    create index(:reactions, [:timeline_item_id])
    create index(:reactions, [:user_id])
  end
end
