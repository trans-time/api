defmodule Api.Repo.Migrations.CreateUserPasswords do
  use Ecto.Migration

  def change do
    create table(:user_passwords) do
      add :password, :text
      add :user_id, references(:users, on_delete: :delete_all), null: false
    end

    create unique_index(:user_passwords, [:user_id])
  end
end
