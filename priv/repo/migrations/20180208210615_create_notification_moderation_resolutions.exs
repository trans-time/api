defmodule Api.Repo.Migrations.CreateNotificationModerationResolutions do
  use Ecto.Migration

  def change do
    create table(:notification_moderation_resolutions) do
      add :notification_id, references(:notifications, on_delete: :delete_all), null: false
      add :flag_id, references(:flags)
    end

    create index(:notification_moderation_resolutions, [:notification_id], using: :hash)
    create index(:notification_moderation_resolutions, [:flag_id], using: :hash)
  end
end
