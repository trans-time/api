defmodule Api.Repo.Migrations.CreateNotificationEmailConfirmations do
  use Ecto.Migration

  def change do
    create table(:notification_email_confirmations) do
      add :notification_id, references(:notifications, on_delete: :delete_all), null: false
    end

    create index(:notification_email_confirmations, [:notification_id], using: :hash)
  end
end
