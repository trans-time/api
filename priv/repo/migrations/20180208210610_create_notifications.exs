defmodule Api.Repo.Migrations.CreateNotifications do
  use Ecto.Migration

  def change do
    create table(:notifications) do
      add :is_read, :boolean, default: false, null: false
      add :is_seen, :boolean, default: false, null: false
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :updated_at, :utc_datetime, null: false
    end

    create index(:notifications, [:user_id], using: :hash)
    create index(:notifications, [:is_seen], using: :hash)
    create index(:timeline_items, ["updated_at DESC"])
  end
end
