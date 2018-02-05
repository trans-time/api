defmodule ApiWeb.UserView do
  use ApiWeb, :view
  use JaSerializer.PhoenixView
  alias ApiWeb.{UserIdentityView, UserProfileView, UserView}

  attributes [:avatar, :display_name, :is_moderator, :pronouns, :username]

  has_many :user_identities,
    serializer: UserIdentityView,
    include: false

  has_one :user_profile,
    serializer: UserProfileView,
    include: false

  def user_profile(%{user_profile: %Ecto.Association.NotLoaded{}, user_profile_id: nil}, _conn), do: nil
  def user_profile(%{user_profile: %Ecto.Association.NotLoaded{}, user_profile_id: id}, _conn), do: %{id: id}
  def user_profile(%{user_profile: user_profile}, _conn), do: user_profile

  def preload(record_or_records, _conn, include_opts) do
    Api.Repo.preload(record_or_records, include_opts)
  end
end
