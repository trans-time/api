defmodule Api.Repo.Migrations.CreateImages do
  use Ecto.Migration

  def change do
    create table(:images) do
      add :filename, :string
      add :filesize, :integer
      add :order, :integer
      add :src, :string
      add :post_id, references(:posts), null: false

      timestamps()
    end

    create index(:images, [:post_id], using: :hash)
  end
end
