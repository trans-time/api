defmodule Api.Repo.Migrations.CreateUserIdentities do
  use Ecto.Migration

  def change do
    create table(:user_identities) do
      add :start_date, :utc_datetime
      add :end_date, :utc_datetime
      add :identity_id, references(:identities, on_delete: :nothing), null: false
      add :user_id, references(:users, on_delete: :nothing), null: false

      timestamps()
    end

    create unique_index(:user_identities, [:identity_id, :user_id])
  end
end
