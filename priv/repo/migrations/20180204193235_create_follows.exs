defmodule Api.Repo.Migrations.CreateFollows do
  use Ecto.Migration

  def change do
    create table(:follows) do
      add :can_view_private, :boolean, default: false, null: false
      add :requested_private, :boolean, default: false, null: false
      add :follower_id, references(:users)
      add :followed_id, references(:users)

      timestamps()
    end

    create index(:follows, [:followed_id, :follower_id])
  end
end
