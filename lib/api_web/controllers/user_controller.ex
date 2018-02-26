import Ecto.Query, only: [where: 2]

defmodule ApiWeb.UserController do
  use ApiWeb, :controller
  use JaResource # Optionally put in web/web.ex
  plug JaResource

  alias Api.Accounts.{CurrentUser, Guardian, User}
  alias Api.Profile.{UserProfile, UserTagSummary}

  def model, do: User

  def handle_create(conn, attributes) do
    User.changeset(%User{
      current_user: %CurrentUser{},
      user_profile: %UserProfile{
        user_tag_summary: %UserTagSummary{}
      }
    }, attributes)
  end

  def filter(_conn, query, "username", username) do
    where(query, username: ^username)
  end
end
