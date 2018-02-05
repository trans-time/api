defmodule ApiWeb.PostView do
  use ApiWeb, :view
  use JaSerializer.PhoenixView
  alias ApiWeb.ImageView

  attributes [:nsfw, :text]

  has_many :images,
    serializer: ImageView
end
