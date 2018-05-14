defmodule Api.Repo.Migrations.CreateNotificationModerationReportRequests do
  use Ecto.Migration

  def change do
    create table(:notification_moderation_report_requests) do
      add :count, :integer, default: 0, null: false
      add :notification_id, references(:notifications, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:notification_moderation_report_requests, [:notification_id], using: :hash)
  end
end
