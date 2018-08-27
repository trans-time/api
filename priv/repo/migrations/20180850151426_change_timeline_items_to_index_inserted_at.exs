defmodule Api.Repo.Migrations.ChangeTimelineItemsToIndexInsertedAt do
  use Ecto.Migration

  def change do
    create index(:timeline_items, ["inserted_at DESC"])
  end
end
