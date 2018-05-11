defmodule Api.Repo.Migrations.CreateBlocks do
  use Ecto.Migration

  def change do
    create table(:blocks) do
      add :blocked_id, references(:users, on_delete: :delete_all), null: false
      add :blocker_id, references(:users, on_delete: :delete_all), null: false

      timestamps()
    end

    create unique_index(:blocks, [:blocked_id, :blocker_id])
    create index(:blocks, [:blocker_id], using: :hash)
  end
end
