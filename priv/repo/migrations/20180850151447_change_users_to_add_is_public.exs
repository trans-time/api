defmodule Api.Repo.Migrations.ChangeUsersToAddIsPublic do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :is_public, :boolean, null: false, default: false
    end

    create index(:users, :is_public)
  end
end
