defmodule Api.Repo.Migrations.CreateFollows do
  use Ecto.Migration

  def change do
    create table(:follows) do
      add :can_view_private, :boolean, default: false, null: false
      add :has_requested_private, :boolean, default: false, null: false
      add :follower_id, references(:users, on_delete: :delete_all), null: false
      add :followed_id, references(:users, on_delete: :delete_all), null: false

      timestamps()
    end

    create unique_index(:follows, [:followed_id, :follower_id])
    create index(:follows, [:follower_id], using: :hash)
    create index(:follows, [:followed_id, :has_requested_private])
  end
end
