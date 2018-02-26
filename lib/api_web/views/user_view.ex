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
    Enum.reduce([
      %{key: :blockeds, view: BlockView},
      %{key: :blockers, view: BlockView},
      %{key: :current_user, view: CurrentUserView},
      %{key: :followeds, view: FollowView},
      %{key: :user_profile, view: UserProfileView},
      %{key: :user_identities, view: UserIdentityView}
    ], %{}, fn(relationship, relationships) ->
      if Ecto.assoc_loaded?(Map.get(user, relationship.key)) do
        Map.put(relationships, relationship.key, %HasMany{
          serializer: relationship.view,
          include: true,
          data: Map.get(user, relationship.key)
        })
      else
        relationships
      end
    end)
  end
end
