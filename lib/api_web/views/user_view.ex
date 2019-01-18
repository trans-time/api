defmodule ApiWeb.UserView do
  use ApiWeb, :view
  use JaSerializer.PhoenixView
  alias ApiWeb.{BlockView, CurrentUserView, FollowView, ModerationReportView, UserIdentityView, UserProfileView, UserTagSummaryView, UserView}

  attributes [:avatar, :display_name, :is_moderator, :is_public, :pronouns, :token, :username]

  def avatar(user) do
    Api.Profile.Avatar.url({user.avatar, user}, :full)
  end

  def preload(record_or_records, _conn, include_opts) do
    Api.Repo.preload(record_or_records, include_opts)
  end

  def relationships(user, _conn) do
    Enum.reduce([
      %{key: :blockeds, view: BlockView},
      %{key: :blockers, view: BlockView},
      %{key: :current_user, view: CurrentUserView},
      %{key: :followeds, view: FollowView},
      %{key: :indictions, view: ModerationReportView},
      %{key: :user_profile, view: UserProfileView},
      %{key: :user_identities, view: UserIdentityView},
      %{key: :user_tag_summaries_about_user, view: UserTagSummaryView},
      %{key: :user_tag_summaries_by_user, view: UserTagSummaryView}
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
