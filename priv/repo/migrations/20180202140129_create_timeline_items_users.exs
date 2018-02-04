defmodule Api.Repo.Migrations.CreateTimelineItemsUsers do
  use Ecto.Migration

  def change do
    create table(:timeline_items_users, primary_key: false) do
      add :user_id, references(:users, on_delete: :nothing)
      add :timeline_item_id, references(:timeline_items, on_delete: :nothing)
    end

    create index(:timeline_items_users, [:user_id])
    create index(:timeline_items_users, [:timeline_item_id])
  end
end
