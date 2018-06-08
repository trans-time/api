defmodule Api.Repo.Migrations.CreateNotificationPrivateRequests do
  use Ecto.Migration

  def change do
    create table(:notification_private_requests) do
      add :notification_id, references(:notifications, on_delete: :delete_all), null: false
    end

    create index(:notification_private_requests, [:notification_id], using: :hash)
  end
end
