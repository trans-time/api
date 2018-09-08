defmodule Api.Repo.Migrations.ChangeUsersToAddIsTrans do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :mail_token, :string, null: false, default: fragment("uuid_generate_v4()")
    end
  end
end
