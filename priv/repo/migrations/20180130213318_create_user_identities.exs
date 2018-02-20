defmodule Api.Repo.Migrations.CreateUserIdentities do
  use Ecto.Migration

  def change do
    create table(:user_identities) do
      add :start_date, :utc_datetime
      add :end_date, :utc_datetime
      add :identity_id, references(:identities, on_delete: :nothing)
      add :user_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    create index(:user_identities, [:identity_id])
    create index(:user_identities, [:user_id])
  end
end
