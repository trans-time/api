defmodule Api.Repo.Migrations.CreateSubscriptions do
  use Ecto.Migration

  def change do
    create table(:subscription_types) do
      add :name, :text
    end

    create unique_index(:subscription_types, [:name])
  end
end
