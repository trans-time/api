defmodule Api.Repo.Migrations.CreateUserTagSummariesUsers do
  use Ecto.Migration

  def change do
    create table(:user_tag_summaries_users, primary_key: false) do
      add :user_id, references(:users, on_delete: :nothing), null: false
      add :user_tag_summary_id, references(:user_tag_summaries, on_delete: :nothing), null: false
    end

    create unique_index(:user_tag_summaries_users, [:user_tag_summary_id, :user_id])
  end
end
