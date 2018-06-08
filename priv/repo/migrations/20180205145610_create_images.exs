defmodule Api.Repo.Migrations.CreateImages do
  use Ecto.Migration

  def change do
    create table(:images) do
      add :order, :integer, null: false
      add :src, :text
      add :post_id, references(:posts, on_delete: :delete_all), null: false
      add :is_marked_for_deletion, :boolean, default: false, null: false
      add :is_marked_for_deletion_by_user, :boolean, default: false, null: false
      add :is_marked_for_deletion_by_moderator, :boolean, default: false, null: false
      add :marked_for_deletion_on, :utc_datetime

      timestamps()
    end

    create index(:images, [:post_id], using: :hash)
    create index(:images, [:is_marked_for_deletion], type: :hash)
    create index(:images, [:marked_for_deletion_on], type: :hash)
  end
end
