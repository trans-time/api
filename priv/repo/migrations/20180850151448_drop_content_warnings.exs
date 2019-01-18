defmodule Api.Repo.Migrations.DropContentWarnings do
  use Ecto.Migration

  def change do
    drop index(:content_warnings, [:name])
    drop index(:content_warnings, ["name gin_trgm_ops"], using: :gin)
    drop index(:content_warnings, ["tagging_count DESC"])
    drop index(:timeline_items_content_warnings, [:content_warning_id, :timeline_item_id])

    drop table(:timeline_items_content_warnings)
    drop table(:content_warnings)

    alter table(:flags) do
      remove :incorrect_content_warning
    end

    alter table(:verdicts) do
      remove :action_change_content_warnings
      remove :previous_content_warnings
    end
  end
end
