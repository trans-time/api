defmodule Api.Repo.Migrations.CreateSubscriptions do
  use Ecto.Migration

  def change do
    create table(:subscriptions) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :subscription_type_id, references(:subscription_types, on_delete: :delete_all), null: false
    end

    create unique_index(:subscriptions, [:user_id, :subscription_type_id])
  end
end
