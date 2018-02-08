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

  def relationships(user, _conn) do
    relationships = %{}

    if Ecto.assoc_loaded?(user.user_profile) do
      relationships = Map.put(relationships, :user_profile, %HasOne{
        serializer: UserProfileView,
        include: true,
        data: user.user_profile
      })
    end
    if Ecto.assoc_loaded?(user.user_identities) do
      relationships = Map.put(relationships, :user_identities, %HasMany{
        serializer: UserIdentityView,
        include: true,
        data: user.user_identities
      })
    end

    relationships
  end
end
