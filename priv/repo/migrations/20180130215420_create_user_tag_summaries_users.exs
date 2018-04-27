defmodule Api.Repo.Migrations.CreateUserTagSummariesUsers do
  use Ecto.Migration

  def change do
    create table(:user_tag_summary_users) do
      add :timeline_item_ids, {:array, :integer}, null: false
      add :user_id, references(:users, on_delete: :nothing), null: false
      add :user_tag_summary_id, references(:user_tag_summaries, on_delete: :nothing), null: false

      timestamps()
    end

    create unique_index(:user_tag_summary_users, [:user_tag_summary_id, :user_id])
  end
end
