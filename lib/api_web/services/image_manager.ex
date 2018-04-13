import Ecto.Query

defmodule ApiWeb.Services.ImageManager do
  alias Api.Timeline.Image
  alias Ecto.Multi

  def insert(attributes) do
    changeset = Image.changeset(%Image{}, attributes)
    
    Multi.new
    |> Multi.insert(:image, changeset)
  end
end
