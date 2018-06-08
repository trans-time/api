defmodule Api.Repo.Migrations.CreateNotificationPrivateGrants do
  use Ecto.Migration

  def change do
    create table(:notification_private_grants) do
      add :follow_id, references(:follows, on_delete: :delete_all), null: false
      add :notification_id, references(:notifications, on_delete: :delete_all), null: false
    end

    create index(:notification_private_grants, [:notification_id], using: :hash)
    create index(:notification_private_grants, [:follow_id], using: :hash)
  end
end
