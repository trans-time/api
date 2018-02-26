defmodule ApiWeb.UserView do
  use ApiWeb, :view
  use JaSerializer.PhoenixView
  alias ApiWeb.{BlockView, CurrentUserView, FollowView, UserIdentityView, UserProfileView, UserView}

  attributes [:avatar, :display_name, :is_moderator, :pronouns, :username]

  has_many :blockeds,
    serializer: BlockView,
    include: false

  has_many :blockers,
    serializer: BlockView,
    include: false

  has_one :current_user,
    serializer: CurrentUserView,
    include: false

  has_many :followeds,
    serializer: FollowView,
    include: false

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
    if Ecto.assoc_loaded?(user.blockeds) do
      relationships = Map.put(relationships, :blockeds, %HasMany{
        serializer: BlockView,
        include: true,
        data: user.blockeds
      })
    end
    if Ecto.assoc_loaded?(user.blockers) do
      relationships = Map.put(relationships, :blockers, %HasMany{
        serializer: BlockView,
        include: true,
        data: user.blockers
      })
    end
    if Ecto.assoc_loaded?(user.current_user) do
      relationships = Map.put(relationships, :current_user, %HasOne{
        serializer: CurrentUserView,
        include: true,
        data: user.current_user
      })
    end
    if Ecto.assoc_loaded?(user.followeds) do
      relationships = Map.put(relationships, :followeds, %HasMany{
        serializer: FollowView,
        include: true,
        data: user.followeds
      })
    end
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
