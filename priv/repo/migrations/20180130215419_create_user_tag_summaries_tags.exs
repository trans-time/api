defmodule Api.Repo.Migrations.CreateUserIndentities do
  use Ecto.Migration

  def change do
    create table(:user_tag_summaries_tags) do
      add :tag_id, references(:tags, on_delete: :nothing)
      add :user_tag_summary_id, references(:user_tag_summaries, on_delete: :nothing)

      timestamps()
    end

    create index(:user_tag_summaries_tags, [:tag_id])
    create index(:user_tag_summaries_tags, [:user_tag_summary_id])
  end
end
