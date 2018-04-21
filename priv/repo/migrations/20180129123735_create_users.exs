defmodule Api.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :avatar, :text
      add :email, :citext, null: false
      add :display_name, :text
      add :is_moderator, :boolean, default: false, null: false
      add :is_banned, :boolean, null: false, default: false
      add :password, :text
      add :pronouns, :text
      add :username, :citext, null: false

      timestamps()
    end

    create unique_index(:users, [:email])
    create unique_index(:users, [:username])
    create index(:users, [:is_banned], using: :hash)
    create index(:users, ["username gin_trgm_ops"], using: :gin)
    create index(:users, ["lower(display_name) gin_trgm_ops"], using: :gin)
  end
end
