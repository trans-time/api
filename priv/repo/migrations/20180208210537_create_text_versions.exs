defmodule Api.Repo.Migrations.CreateTextVersions do
  use Ecto.Migration

  def change do
    create table(:text_versions) do
      add :text, :text
      add :attribute, :text
      add :comment_id, references(:comments, on_delete: :delete_all)
      add :post_id, references(:posts, on_delete: :delete_all)

      timestamps()
    end

    create index(:text_versions, [:comment_id], using: :hash)
    create index(:text_versions, [:post_id], using: :hash)
    create constraint(:text_versions, :only_one_versionable, check: "count_not_nulls(comment_id, post_id) = 1")
  end
end
