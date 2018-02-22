defmodule Api.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :avatar, :string
      add :email, :citext, null: false
      add :display_name, :string
      add :is_moderator, :boolean, default: false, null: false
      add :password, :string
      add :pronouns, :string
      add :username, :citext, null: false

      timestamps()
    end

    create unique_index(:users, [:email, :username])
    create index(:users, [:display_name])
  end
end
