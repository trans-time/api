defmodule Api.Repo.Migrations.CreateFollows do
  use Ecto.Migration

  def change do
    create table(:follows) do
      add :can_view_private, :boolean, default: false, null: false
      add :requested_private, :boolean, default: false, null: false
      add :follower_id, references(:users), null: false
      add :followed_id, references(:users), null: false

      timestamps()
    end

    create unique_index(:follows, [:followed_id, :follower_id])
    create index(:follows, [:follower_id], using: :hash)
    create index(:follows, [:followed_id, :requested_private])
  end
end
