defmodule Api.Repo.Migrations.CreateMailUnlockTokens do
  use Ecto.Migration

  def change do
    create table(:mail_unlock_tokens) do
      add :token, :string, null: false, default: fragment("uuid_generate_v4()")
      add :user_id, references(:users, on_delete: :delete_all), null: false
    end

    create unique_index(:mail_unlock_tokens, :token)
  end
end
