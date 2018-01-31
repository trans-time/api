defmodule Api.Repo.Migrations.CreateUserProfiles do
  use Ecto.Migration

  def change do
    create table(:user_profiles) do
      add :description, :string
      add :total_posts, :integer
      add :website, :string
      add :user_id, references(:users)

      timestamps()
    end

    create index(:user_profiles, [:user_id])
  end
end
