defmodule ApiWeb.ContentWarningView do
  use ApiWeb, :view
  use JaSerializer.PhoenixView

  attributes [:name]
end
