defmodule Api.Repo.Migrations.CreateUserTagSummariesUsers do
  use Ecto.Migration

  def change do
    create table(:user_tag_summaries_users, primary_key: false) do
      add :user_id, references(:users, on_delete: :nothing)
      add :user_tag_summary_id, references(:user_tag_summaries, on_delete: :nothing)
    end

    create index(:user_tag_summaries_users, [:user_id])
    create index(:user_tag_summaries_users, [:user_tag_summary_id])
  end
end
