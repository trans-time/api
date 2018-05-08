import Ecto.Query

defmodule ApiWeb.Services.ImageManager do
  alias Api.Timeline.{Image,ImageFile}
  alias Ecto.Multi

  def delete(record, attributes, multi_name \\ :image) do
    # Enum.each(ImageFile.get_versions(), fn (version) ->
    #   ImageFile.delete({ImageFile.url({record.src, record}, version), record})
    # end)
    changeset = Image.private_changeset(record, Map.merge(%{deleted: true, deleted_at: DateTime.utc_now()}, attributes))
    Multi.new
    |> Multi.update(multi_name, changeset)
  end

  def undelete(record, attributes, multi_name \\ :image) do
    changeset = Image.private_changeset(record, attributes)

    Multi.new
    |> Multi.update(multi_name, changeset)
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
