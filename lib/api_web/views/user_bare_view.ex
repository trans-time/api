defmodule ApiWeb.UserBareView do
  use ApiWeb, :view
  use JaSerializer.PhoenixView

  attributes [:display_name, :username]
  def type(_post,_conn), do: "user"
end
