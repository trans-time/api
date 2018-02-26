import Ecto.Query, only: [where: 2]

defmodule ApiWeb.UserController do
  use ApiWeb, :controller
  use JaResource # Optionally put in web/web.ex
  plug JaResource

  alias Api.Accounts.{CurrentUser, Guardian, User}
  alias Api.Profile.{UserProfile, UserTagSummary}
  alias Ecto.Multi

  def model, do: User

  def handle_create(conn, attributes) do
    changeset = User.changeset(%User{
      current_user: %CurrentUser{},
      user_profile: %UserProfile{}
    }, attributes)

    Multi.new
    |> Multi.insert(:user, changeset)
    |> Multi.run(:user_tag_summary, fn %{user: user} ->
      %UserTagSummary{
        user_profile: user.user_profile,
        summary: Map.put(%{}, user.id, %{tags: %{}, users: %{}, private: []})
      }
      |> Api.Repo.insert
    end)
  end

  def filter(_conn, query, "username", username) do
    where(query, username: ^username)
  end
end
