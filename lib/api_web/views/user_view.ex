defmodule ApiWeb.UserView do
  use JSONAPI.View, type: "users"
  alias ApiWeb.UserView

  def render("show.json", %{user: user, conn: conn, params: params}) do
    UserView.show(user, conn, params)
  end

  def fields do
    [:avatar, :display_name, :is_moderator, :pronouns, :username]
  end
end
