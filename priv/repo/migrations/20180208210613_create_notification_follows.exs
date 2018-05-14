defmodule Api.Repo.Migrations.CreateNotificationFollows do
  use Ecto.Migration

  def change do
    create table(:notification_follows) do
      add :follow_count, :integer, default: 0, null: false
      add :notification_id, references(:notifications, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:notification_follows, [:notification_id], using: :hash)
  end
end
