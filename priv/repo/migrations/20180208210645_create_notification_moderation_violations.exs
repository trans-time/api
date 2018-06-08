defmodule Api.Repo.Migrations.CreateNotificationModerationViolations do
  use Ecto.Migration

  def change do
    create table(:notification_moderation_violations) do
      add :notification_id, references(:notifications, on_delete: :delete_all), null: false
      add :moderation_report_id, references(:moderation_reports)
    end

    create index(:notification_moderation_violations, [:notification_id], using: :hash)
    create index(:notification_moderation_violations, [:moderation_report_id], using: :hash)
  end
end
