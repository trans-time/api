defmodule Api.Repo.Migrations.CreateNotificationModerationReportRequests do
  use Ecto.Migration

  def change do
    create table(:notification_moderation_report_resolveds) do
      add :notification_id, references(:notifications, on_delete: :delete_all), null: false
      add :flag_id, references(:flags, on_delete: :delete_all)

      timestamps()
    end

    create index(:notification_moderation_report_resolveds, [:notification_id], using: :hash)
    create index(:notification_moderation_report_resolveds, [:flag_id], using: :hash)
  end
end
