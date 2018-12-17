defmodule ApiWeb.ImageView do
  use ApiWeb, :view
  use JaSerializer.PhoenixView

  attributes [:caption, :order, :src, :is_marked_for_deletion]

  def src(image) do
    Api.Timeline.ImageFile.url({image.src, image}, :full_750)
  end
end
