defmodule Api.Repo.Migrations.CreatePosts do
  use Ecto.Migration

  def change do
    create table(:posts) do
      add :nsfw, :boolean, default: false, null: false
      add :text, :string
      add :comment_count, :integer, default: 0, null: false
      add :moon_count, :integer, default: 0, null: false
      add :star_count, :integer, default: 0, null: false
      add :sun_count, :integer, default: 0, null: false

      timestamps()
    end

    alter table("timeline_items") do
      add :post_id, references(:posts)
    end

    create index(:timeline_items, [:post_id])
  end
end
