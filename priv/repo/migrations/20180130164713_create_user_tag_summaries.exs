defmodule Api.Repo.Migrations.CreateUserTagSummaries do
  use Ecto.Migration

  def change do
    create table(:user_tag_summaries) do
      add :summary, :map
      add :user_profile_id, references(:user_profiles)

      timestamps()
    end
    
    create index(:user_tag_summaries, [:user_profile_id])
  end
end
