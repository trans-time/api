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
        author: user,
        subject: user
      }
      |> Api.Repo.insert
    end)
  end
end
