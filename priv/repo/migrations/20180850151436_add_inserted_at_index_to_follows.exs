defmodule Api.Repo.Migrations.AddInsertedAtIndexToFollows do
  use Ecto.Migration

  def change do
    create index(:follows, ["inserted_at DESC"])
    create index(:reactions, ["inserted_at DESC"])
  end
end
