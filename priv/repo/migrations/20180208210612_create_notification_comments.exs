defmodule Api.Repo.Migrations.CreateNotificationComments do
  use Ecto.Migration

  def change do
    create table(:notification_comments) do
      add :comment_count, :integer, default: 0, null: false
      add :notification_id, references(:notifications, on_delete: :delete_all), null: false
      add :timeline_item_id, references(:timeline_items, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:notification_comments, [:notification_id], using: :hash)
    create index(:notification_comments, [:timeline_item_id], using: :hash)
  end
end
