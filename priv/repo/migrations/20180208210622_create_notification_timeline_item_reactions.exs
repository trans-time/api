defmodule Api.Repo.Migrations.CreateNotificationTimelineItemReactions do
  use Ecto.Migration

  def change do
    create table(:notification_timeline_item_reactions) do
      add :notification_id, references(:notifications, on_delete: :delete_all), null: false
      add :timeline_item_id, references(:timeline_items), null: false
    end

    create index(:notification_timeline_item_reactions, [:notification_id], using: :hash)
    create index(:notification_timeline_item_reactions, [:timeline_item_id], using: :hash)
  end
end
