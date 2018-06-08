defmodule Api.Repo.Migrations.CreateNotificationTimelineItemComments do
  use Ecto.Migration

  def change do
    create table(:notification_timeline_item_comments) do
      add :notification_id, references(:notifications, on_delete: :delete_all), null: false
      add :comment_id, references(:comments, on_delete: :delete_all), null: false
    end

    create index(:notification_timeline_item_comments, [:notification_id], using: :hash)
    create index(:notification_timeline_item_comments, [:comment_id], using: :hash)
  end
end
