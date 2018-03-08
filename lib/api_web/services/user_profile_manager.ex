import Ecto.Query

defmodule ApiWeb.Services.UserProfileManager do
  alias Api.Accounts.User
  alias Api.Profile.{Identity, UserProfile}
  alias Ecto.Multi

  def update(record, attributes) do
    user_attributes = Map.take(attributes, ["avatar", "display_name", "pronouns"])
    user_changeset = User.changeset(Api.Repo.get(User, record.user_id), user_attributes)
    user_profile_changeset = UserProfile.changeset(record, attributes)

    Multi.new
    |> Multi.update(:user, user_changeset)
    |> Multi.update(:user_profile, user_profile_changeset)
  end
end
