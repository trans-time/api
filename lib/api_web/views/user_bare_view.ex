defmodule ApiWeb.UserBareView do
  use ApiWeb, :view
  use JaSerializer.PhoenixView

  attributes [:avatar, :display_name, :is_moderator, :pronouns, :username]
  def type(_post,_conn), do: "user"
end
