defmodule ApiWeb.PostView do
  use ApiWeb, :view
  use JaSerializer.PhoenixView
  alias ApiWeb.ImageView

  attributes [:nsfw, :text, :total_comments, :total_moons, :total_stars, :total_suns]

  has_many :images,
    serializer: ImageView
end
