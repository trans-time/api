defmodule Api.Repo.Migrations.ChangeImagesTableToUseUuids do
  use Ecto.Migration

  def change do
    execute "CREATE EXTENSION \"uuid-ossp\";", "DROP EXTENSION \"uuid-ossp\";"
    alter table(:images) do
      remove :id # remove the existing id column
      add :id, :uuid, primary_key: true, default: fragment("uuid_generate_v4()")
    end
  end
end
