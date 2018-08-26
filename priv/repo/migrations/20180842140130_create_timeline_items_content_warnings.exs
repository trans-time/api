defmodule Api.Repo.Migrations.CreateTimelineItemsContentWarnings do
  use Ecto.Migration

  def change do
    create table(:timeline_items_content_warnings, primary_key: false) do
      add :content_warning_id, references(:content_warnings, on_delete: :delete_all), null: false
      add :timeline_item_id, references(:timeline_items, on_delete: :delete_all), null: false
    end

    create unique_index(:timeline_items_content_warnings, [:content_warning_id, :timeline_item_id])
  end
end
