defmodule Api.Repo.Migrations.CreateMailPasswordResetTokens do
  use Ecto.Migration

  def change do
    create table(:mail_password_reset_tokens) do
      add :token, :string, null: false, default: fragment("uuid_generate_v4()")
      add :user_id, references(:users, on_delete: :delete_all), null: false

      timestamps()
    end

    create unique_index(:mail_password_reset_tokens, :token)
    create index(:mail_password_reset_tokens, :inserted_at)
  end
end
