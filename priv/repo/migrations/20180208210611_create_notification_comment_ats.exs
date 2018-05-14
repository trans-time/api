defmodule Api.Repo.Migrations.CreateNotificationCommentAts do
  use Ecto.Migration

  def change do
    create table(:notification_comment_ats) do
      add :notification_id, references(:notifications, on_delete: :delete_all), null: false
      add :comment_id, references(:comments, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:notification_comment_ats, [:notification_id], using: :hash)
    create index(:notification_comment_ats, [:comment_id], using: :hash)
  end
end
