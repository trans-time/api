defmodule Api.Repo.Migrations.CreateFlags do
  use Ecto.Migration

  def change do
    create table(:flags) do
      add :text, :text
      add :bot, :boolean, default: false, null: false
      add :illicit_activity, :boolean, default: false, null: false
      add :trolling, :boolean, default: false, null: false
      add :unconsenting_image, :boolean, default: false, null: false
      add :unmarked_NSFW, :boolean, default: false, null: false
      add :comment_id, references(:comments, on_delete: :nothing)
      add :post_id, references(:posts, on_delete: :nothing)
      add :user_id, references(:users, on_delete: :nothing), null: false
      add :moderation_report_id, references(:moderation_reports, on_delete: :nothing), null: false

      timestamps()
    end

    create index(:flags, [:moderation_report_id], using: :hash)
    create constraint(:flags, :only_one_flaggable, check: "count_not_nulls(comment_id, post_id) = 1")
  end
end
