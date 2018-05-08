defmodule ApiWeb.ImageView do
  use ApiWeb, :view
  use JaSerializer.PhoenixView

  attributes [:order, :src, :deleted]

  def src(image) do
    Api.Timeline.ImageFile.url({image.src, image}, :full)
  end
end
