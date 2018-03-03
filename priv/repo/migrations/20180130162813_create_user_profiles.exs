defmodule Api.Repo.Migrations.CreateUserProfiles do
  use Ecto.Migration

  def change do
    create table(:user_profiles) do
      add :description, :string
      add :post_count, :integer, default: 0, null: false
      add :website, :string
      add :user_id, references(:users), null: false

      timestamps()
    end

    create unique_index(:user_profiles, [:user_id])
  end
end
