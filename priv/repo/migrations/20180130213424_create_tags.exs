defmodule Api.Repo.Migrations.CreateTags do
  use Ecto.Migration

  def change do
    create table(:tags) do
      add :name, :citext
      add :tagging_count, :integer, default: 0, null: false

      timestamps()
    end

    create unique_index(:tags, [:name])
    create index(:tags, ["name gin_trgm_ops"], using: :gin)
    create index(:tags, ["tagging_count DESC"])
  end
end
