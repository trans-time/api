defmodule Api.Repo.Migrations.CreateIdentities do
  use Ecto.Migration

  def change do
    create table(:identities) do
      add :name, :citext
      add :user_identity_count, :integer, default: 0, null: false

      timestamps()
    end

    create unique_index(:identities, [:name])
    create index(:identities, ["name gin_trgm_ops"], using: :gin)
    create index(:identities, ["user_identity_count DESC"])
  end
end
