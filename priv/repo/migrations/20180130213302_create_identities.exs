defmodule Api.Repo.Migrations.CreateIdentities do
  use Ecto.Migration

  def change do
    create table(:identities) do
      add :name, :string

      timestamps()
    end

  end
end
