defmodule ApiWeb.EmailChangeView do
  use ApiWeb, :view
  use JaSerializer.PhoenixView

  attributes [:email]
end
