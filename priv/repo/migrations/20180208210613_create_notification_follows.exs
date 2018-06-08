defmodule Api.Repo.Migrations.CreateNotificationFollows do
  use Ecto.Migration

  def change do
    create table(:notification_follows) do
      add :follow_id, references(:follows, on_delete: :delete_all), null: false
      add :notification_id, references(:notifications, on_delete: :delete_all), null: false
    end

    create index(:notification_follows, [:notification_id], using: :hash)
    create index(:notification_follows, [:follow_id], using: :hash)
  end
end
