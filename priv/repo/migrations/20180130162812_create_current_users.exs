defmodule Api.Repo.Migrations.CreateCurrentUsers do
  use Ecto.Migration

  def change do
    create table(:current_users) do
      add :language, :string, default: "en-us", null: false
      add :unread_notification_count, :integer, default: 0, null: false
      add :user_id, references(:users)

      timestamps()
    end

    create index(:current_users, [:user_id])
  end
end
