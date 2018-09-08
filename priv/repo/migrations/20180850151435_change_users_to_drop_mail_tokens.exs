defmodule Api.Repo.Migrations.ChangeUsersToDropMailTokens do
  use Ecto.Migration

  def change do
    alter table(:users) do
      remove :mail_confirmation_token
      remove :mail_token
      remove :new_email
    end
  end
end
