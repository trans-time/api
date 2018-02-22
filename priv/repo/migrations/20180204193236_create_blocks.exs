defmodule Api.Repo.Migrations.CreateBlocks do
  use Ecto.Migration

  def change do
    create table(:blocks) do
      add :blocker_id, references(:users)
      add :blocked_id, references(:users)

      timestamps()
    end

    create index(:blocks, [:blocker_id, :blocked_id])
  end
end
