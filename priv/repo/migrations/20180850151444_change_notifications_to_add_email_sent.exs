defmodule Api.Repo.Migrations.ChangeNotificationsToAddEmailSent do
  use Ecto.Migration

  def change do
    alter table(:notifications) do
      add :is_emailed, :boolean, default: false, null: false
    end

    create index(:notifications, :is_emailed)
  end
end
