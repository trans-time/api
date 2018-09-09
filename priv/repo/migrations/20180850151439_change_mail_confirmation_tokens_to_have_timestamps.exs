defmodule Api.Repo.Migrations.ChangeMailConfirmationTokensToHaveTimestamps do
  use Ecto.Migration

  def change do
    alter table(:mail_confirmation_tokens) do
      timestamps default: "2000-01-01 01:00:00.000", null: false
    end

    create index(:mail_confirmation_tokens, :inserted_at)
  end
end
