defmodule Api.Repo.Migrations.CreateModerationReports do
  use Ecto.Migration

  def change do
    create table(:moderation_reports) do
      add :moderator_comment, :text
      add :resolved, :boolean, default: false, null: false
      add :was_violation, :boolean, default: false, null: false
      add :action_banned_user, :boolean, default: false, null: false
      add :action_deleted_flaggable, :boolean, default: false, null: false
      add :action_ignore_flags, :boolean, default: false, null: false
      add :action_lock_comments, :boolean, default: false, null: false
      add :ban_user_until, :utc_datetime
      add :lock_comments_until, :utc_datetime
      add :comment_id, references(:comments, on_delete: :nothing)
      add :post_id, references(:posts, on_delete: :nothing)
      add :indicted_id, references(:users, on_delete: :nothing), null: false
      add :moderator_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    create index(:moderation_reports, [:comment_id])
    create index(:moderation_reports, [:resolved])
    create index(:moderation_reports, [:post_id])
    create index(:moderation_reports, [:indicted_id])
    create constraint(:moderation_reports, :only_one_flaggable, check: "count_not_nulls(comment_id, post_id) = 1")
  end
end
