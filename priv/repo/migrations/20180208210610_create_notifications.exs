defmodule Api.Repo.Migrations.CreateNotifications do
  use Ecto.Migration

  def change do
    create table(:notifications) do
      add :read, :boolean, default: false, null: false
      add :seen, :boolean, default: false, null: false
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :updated_at, :utc_datetime, null: false
    end

    create index(:notifications, [:user_id], using: :hash)
    create index(:notifications, [:seen], using: :hash)
    create index(:timeline_items, ["updated_at DESC"])
  end
end
