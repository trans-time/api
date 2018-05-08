defmodule Api.Repo.Migrations.CreateImages do
  use Ecto.Migration

  def change do
    create table(:images) do
      add :order, :integer, null: false
      add :src, :text
      add :post_id, references(:posts), null: false
      add :deleted, :boolean, default: false, null: false
      add :deleted_by_user, :boolean, default: false, null: false
      add :deleted_by_moderator, :boolean, default: false, null: false
      add :deleted_at, :utc_datetime

      timestamps()
    end

    create index(:images, [:post_id], using: :hash)
    create index(:images, [:deleted], type: :hash)
    create index(:images, [:deleted_at], type: :hash)
  end
end
