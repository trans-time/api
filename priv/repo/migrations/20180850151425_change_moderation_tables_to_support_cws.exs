defmodule Api.Repo.Migrations.ChangeModerationTablesToSupportCws do
  use Ecto.Migration

  def change do
    alter table(:timeline_items) do
      remove :maturity_rating
    end

    alter table(:flags) do
      remove :incorrect_maturity_rating
      add :incorrect_content_warning, :boolean, default: false, null: false
    end

    alter table(:verdicts) do
      remove :action_change_maturity_rating
      remove :previous_maturity_rating
      add :action_change_content_warnings, :text
      add :previous_content_warnings, :text
    end
  end
end
