defmodule Api.Repo.Migrations.ChangeImagesToAddCaption do
  use Ecto.Migration

  def change do
    alter table(:images) do
      add :caption, :string
    end
  end
end
