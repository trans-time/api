defmodule Api.Repo.Migrations.ChangeUsersToAddIsTrans do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :is_trans, :boolean, default: true, null: false
    end

    create index(:users, :is_trans)
  end
end
