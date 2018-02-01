defmodule ApiWeb.TagView do
  use ApiWeb, :view
  use JaSerializer.PhoenixView

  attributes [:name]
end
