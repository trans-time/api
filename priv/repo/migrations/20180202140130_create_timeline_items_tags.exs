defmodule Api.Repo.Migrations.CreateTimelineItemsTags do
  use Ecto.Migration

  def change do
    create table(:timeline_items_tags, primary_key: false) do
      add :tag_id, references(:tags, on_delete: :nothing)
      add :timeline_item_id, references(:timeline_items, on_delete: :nothing)
    end

    create index(:timeline_items_tags, [:tag_id])
    create index(:timeline_items_tags, [:timeline_item_id])
  end
end
