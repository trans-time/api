defmodule Api.Repo.Migrations.CreateTags do
  use Ecto.Migration

  def change do
    create table(:tags) do
      add :name, :citext

      timestamps()
    end

    create unique_index(:tags, [:name])
    create index(:tags, ["name gin_trgm_ops"], using: :gin)
  end
end
