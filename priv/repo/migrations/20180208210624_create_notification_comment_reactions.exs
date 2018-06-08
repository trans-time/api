defmodule Api.Repo.Migrations.CreateNotificationCommentReactions do
  use Ecto.Migration

  def change do
    create table(:notification_comment_reactions) do
      add :notification_id, references(:notifications, on_delete: :delete_all), null: false
      add :comment_id, references(:comments, on_delete: :delete_all), null: false
    end

    create index(:notification_comment_reactions, [:notification_id], using: :hash)
    create index(:notification_comment_reactions, [:comment_id], using: :hash)
  end
end
