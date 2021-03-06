defmodule Api.Repo.Migrations.CreateVerdicts do
  use Ecto.Migration

  def change do
    create table(:verdicts) do
      add :moderator_comment, :text
      add :was_violation, :boolean, default: false, null: false
      add :action_banned_user, :boolean, default: false, null: false
      add :action_mark_flaggable_for_deletion, :boolean, default: false, null: false
      add :action_ignore_flags, :boolean, default: false, null: false
      add :action_lock_comments, :boolean, default: false, null: false
      add :action_change_maturity_rating, :integer
      add :action_mark_images_for_deletion, :boolean, default: false, null: false
      add :delete_image_ids, {:array, :integer}, null: false
      add :ban_user_until, :utc_datetime
      add :lock_comments_until, :utc_datetime
      add :previous_maturity_rating, :integer
      add :moderator_id, references(:users, on_delete: :nothing), null: false
      add :moderation_report_id, references(:moderation_reports, on_delete: :nothing), null: false

      timestamps()
    end

    create index(:verdicts, [:moderation_report_id])
  end
end
