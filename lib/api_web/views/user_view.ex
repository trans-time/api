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

  def preload(record_or_records, _conn, include_opts) do
    Api.Repo.preload(record_or_records, include_opts)
  end
end
