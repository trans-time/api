defmodule Api.Repo.Migrations.ChangeUsersToAddMailConfirmation do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :mail_confirmation_token, :string, null: false, default: fragment("uuid_generate_v4()")
      add :email_is_confirmed, :boolean, null: false, default: false
      add :new_email, :string
    end
  end
end
