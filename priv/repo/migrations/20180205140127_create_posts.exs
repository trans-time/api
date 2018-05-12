defmodule Api.Repo.Migrations.CreatePosts do
  use Ecto.Migration

  def change do
    create table(:posts) do
      add :text, :text
      add :timeline_item_id, references(:timeline_items, on_delete: :delete_all)

      timestamps()
    end

    create index(:posts, [:timeline_item_id], using: :hash)
  end
end
