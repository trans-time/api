defmodule ApiWeb.ImageView do
  use ApiWeb, :view
  use JaSerializer.PhoenixView

  attributes [:filename, :filesize, :order, :src]
end
