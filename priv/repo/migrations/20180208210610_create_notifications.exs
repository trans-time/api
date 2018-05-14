defmodule Api.Repo.Migrations.CreateNotifications do
  use Ecto.Migration

  def change do
    create table(:notifications) do
      add :read, :boolean, default: false, null: false
      add :seen, :boolean, default: false, null: false
      add :under_moderation, :boolean, default: false, null: false
      add :user_id, references(:users, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:notifications, [:user_id], using: :hash)
  end
end
