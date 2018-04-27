defmodule Api.Repo.Migrations.CreateUserTagSummaries do
  use Ecto.Migration

  def change do
    create table(:user_tag_summaries) do
      add :private_timeline_item_ids, {:array, :integer}, null: false
      add :author_id, references(:users), null: false
      add :subject_id, references(:users), null: false

      timestamps()
    end

    create unique_index(:user_tag_summaries, [:subject_id, :author_id])
    create index(:user_tag_summaries, [:author_id], type: :hash)
  end
end
