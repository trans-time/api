defmodule Api.Repo.Migrations.CreateNotificationTimelineItemReactionV2s do
  use Ecto.Migration

  def change do
    create table(:notification_timeline_item_reaction_v2s) do
      add :notification_id, references(:notifications, on_delete: :delete_all), null: false
      add :reaction_id, references(:reactions), null: false
    end

    create index(:notification_timeline_item_reaction_v2s, [:notification_id], using: :hash)
    create index(:notification_timeline_item_reaction_v2s, [:reaction_id], using: :hash)
  end
end
