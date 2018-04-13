defmodule Api.Repo.Migrations.CreateImages do
  use Ecto.Migration

  def change do
    create table(:images) do
      add :order, :integer, null: false
      add :src, :text
      add :post_id, references(:posts), null: false

      timestamps()
    end

    create index(:images, [:post_id], using: :hash)
  end
end
