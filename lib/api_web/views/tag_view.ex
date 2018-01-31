defmodule ApiWeb.TagView do
  use JSONAPI.View, type: "tags"

  def fields do
    [:name]
  end
end
