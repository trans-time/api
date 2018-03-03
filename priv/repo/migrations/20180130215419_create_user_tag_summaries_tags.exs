defmodule Api.Repo.Migrations.CreateUserTagSummariesTags do
  use Ecto.Migration

  def change do
    create table(:user_tag_summaries_tags, primary_key: false) do
      add :tag_id, references(:tags, on_delete: :nothing), null: false
      add :user_tag_summary_id, references(:user_tag_summaries, on_delete: :nothing), null: false
    end

    create unique_index(:user_tag_summaries_tags, [:user_tag_summary_id, :tag_id])
  end
end
