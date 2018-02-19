defmodule ApiWeb.PostView do
  use ApiWeb, :view
  use JaSerializer.PhoenixView
  alias ApiWeb.ImageView

  attributes [:nsfw, :text, :comment_count, :moon_count, :star_count, :sun_count]

  has_many :images,
    serializer: ImageView
end
