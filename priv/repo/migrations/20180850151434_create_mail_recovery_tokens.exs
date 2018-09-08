defmodule Api.Repo.Migrations.CreateMailRecoveryTokens do
  use Ecto.Migration

  def change do
    create table(:mail_recovery_tokens) do
      add :token, :string, null: false, default: fragment("uuid_generate_v4()")
      add :email, :string, null: false
      add :user_id, references(:users, on_delete: :delete_all), null: false
    end

    create unique_index(:mail_recovery_tokens, :token)
  end
end
