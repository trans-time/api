defmodule Api.Repo.Migrations.CreateNotificationModerationRequests do
  use Ecto.Migration

  def change do
    create table(:notification_moderation_requests) do
      add :notification_id, references(:notifications, on_delete: :delete_all), null: false
    end

    create index(:notification_moderation_requests, [:notification_id], using: :hash)
  end
end
