defmodule Api.Repo.Migrations.CreateModerationReports do
  use Ecto.Migration

  def change do
    create table(:moderation_reports) do
      add :moderator_comment, :text
      add :resolved, :boolean, default: false, null: false
      add :should_ignore, :boolean, default: false, null: false
      add :was_violation, :boolean, default: false, null: false
      add :comment_id, references(:comments, on_delete: :nothing)
      add :timeline_item_id, references(:timeline_items, on_delete: :nothing)
      add :indicted_id, references(:users, on_delete: :nothing), null: false
      add :moderator_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    create index(:moderation_reports, [:comment_id])
    create index(:moderation_reports, [:resolved])
    create index(:moderation_reports, [:should_ignore])
    create index(:moderation_reports, [:was_violation])
    create index(:moderation_reports, [:timeline_item_id])
    create index(:moderation_reports, [:indicted_id])
    create constraint(:moderation_reports, :only_one_flaggable, check: "count_not_nulls(comment_id, timeline_item_id) = 1")
  end
end
