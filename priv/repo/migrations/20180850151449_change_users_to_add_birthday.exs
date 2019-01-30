defmodule Api.Repo.Migrations.ChangeUsersToAddBirthday do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :birthday, :utc_datetime, [null: false, default: fragment("now()")]
    end
  end
end
