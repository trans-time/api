defmodule Api.Repo.Migrations.CreateIdentities do
  use Ecto.Migration

  def change do
    create table(:identities) do
      add :name, :string

      timestamps()
    end

    create unique_index(:identities, [:name])
    create index(:identities, ["lower(name) gin_trgm_ops"], using: :gin)
  end
end
