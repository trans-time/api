defmodule Api.Repo.Migrations.CreateNotificationTimelineItemAts do
  use Ecto.Migration

  def change do
    create table(:notification_timeline_item_ats) do
      add :notification_id, references(:notifications, on_delete: :delete_all), null: false
      add :timeline_item_id, references(:timeline_items)
    end

    create index(:notification_timeline_item_ats, [:notification_id], using: :hash)
    create index(:notification_timeline_item_ats, [:timeline_item_id], using: :hash)
  end
end
