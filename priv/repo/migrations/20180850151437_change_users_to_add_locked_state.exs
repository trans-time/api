defmodule Api.Repo.Migrations.ChangeUsersToAddLockedState do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :is_locked, :boolean, null: false, default: false
      add :consecutive_failed_logins, :integer, default: 0, null: false
    end
  end
end
