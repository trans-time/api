defmodule Api.Repo.Migrations.CreateIdentities do
  use Ecto.Migration

  def change do
    create table(:identities) do
      add :name, :citext

      timestamps()
    end

    create unique_index(:identities, [:name])
    create index(:identities, ["name gin_trgm_ops"], using: :gin)
  end
end
