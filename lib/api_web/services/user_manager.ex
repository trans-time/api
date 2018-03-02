import Ecto.Query

defmodule ApiWeb.Services.UserManager do
  alias Api.Accounts.{CurrentUser, User}
  alias Api.Profile.{UserProfile, UserTagSummary}
  alias Ecto.Multi

  def insert_user(attributes) do
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
end
