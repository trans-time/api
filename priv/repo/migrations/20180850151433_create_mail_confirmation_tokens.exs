defmodule Api.Repo.Migrations.CreateMailConfirmationTokens do
  use Ecto.Migration

  def change do
    create table(:mail_confirmation_tokens) do
      add :token, :string, null: false, default: fragment("uuid_generate_v4()")
      add :email, :string
      add :reminder_was_sent, :boolean, null: false, default: false
      add :user_id, references(:users, on_delete: :delete_all), null: false
    end

    create unique_index(:mail_confirmation_tokens, :token)
    create index(:mail_confirmation_tokens, :reminder_was_sent)
  end
end
