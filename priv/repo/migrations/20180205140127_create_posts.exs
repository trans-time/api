defmodule Api.Repo.Migrations.CreatePosts do
  use Ecto.Migration

  def change do
    create table(:posts) do
      add :text, :text

      timestamps()
    end

    alter table("timeline_items") do
      add :post_id, references(:posts)
    end
    create constraint(:timeline_items, :only_one_timelineable, check: "count_not_nulls(post_id) = 1")
    create index(:timeline_items, [:post_id], using: :hash)
  end
end
