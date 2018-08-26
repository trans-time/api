defmodule Api.Repo.Migrations.CreateContentWarnings do
  use Ecto.Migration

  def change do
    create table(:content_warnings) do
      add :name, :citext
      add :tagging_count, :integer, default: 0, null: false

      timestamps()
    end

    create unique_index(:content_warnings, [:name])
    create index(:content_warnings, ["name gin_trgm_ops"], using: :gin)
    create index(:content_warnings, ["tagging_count DESC"])
  end
end
