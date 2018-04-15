import Ecto.Query

defmodule ApiWeb.Services.ImageManager do
  alias Api.Timeline.{Image,ImageFile}
  alias Ecto.Multi

  def delete(record) do
    Enum.each(ImageFile.get_versions(), fn (version) ->
      ImageFile.delete({ImageFile.url({record.src, record}, version), record})
    end)
    Multi.new
    |> Multi.delete(:image, record)
  end

  def insert(attributes) do
    changeset = Image.changeset(%Image{}, attributes)

    Multi.new
    |> Multi.insert(:image, changeset)
  end

  def update(record, attributes) do
    changeset = Image.changeset(record, attributes)

    Multi.new
    |> Multi.update(:image, changeset)
  end
end
