defmodule ApiWeb.PostView do
  use ApiWeb, :view
  use JaSerializer.PhoenixView
  alias ApiWeb.{ImageView, ReactionView, TimelineItemView}

  attributes [:nsfw, :text, :comment_count, :moon_count, :star_count, :sun_count]

  has_one :timeline_item,
    serializer: TimelineItemView,
    include: false

  has_many :images,
    serializer: ImageView

  has_many :reactions,
    serializer: ReactionView

  def timeline_item(%{timeline_item: %Ecto.Association.NotLoaded{}, timeline_item_id: nil}, _conn), do: nil
  def timeline_item(%{timeline_item: %Ecto.Association.NotLoaded{}, timeline_item_id: id}, _conn), do: %{id: id}
  def timeline_item(%{timeline_item: timeline_item}, _conn), do: timeline_item

  def preload(record_or_records, _conn, include_opts) do
    Api.Repo.preload(record_or_records, include_opts)
  end

  # def relationships(post, conn) do
  #   current_user_id = Api.Accounts.Guardian.Plug.current_claims(conn)["sub"]
  #
  #   case current_user_id do
  #     nil -> super(conn, record)
  #     _ do
  #       relationships = super(post, conn)
  #       relationships.reactions = %HasMany{
  #         serializer: ReactionView,
  #         include: true,
  #         data: Api.Repo.all(from r in Reaction, where: r.user_id == current_user_id and r.)
  #       }
  #     end
  #   end
  #
  #   # Enum.reduce([
  #   #   %{key: :blockeds, view: BlockView},
  #   #   %{key: :blockers, view: BlockView},
  #   #   %{key: :current_user, view: CurrentUserView},
  #   #   %{key: :followeds, view: FollowView},
  #   #   %{key: :user_profile, view: UserProfileView},
  #   #   %{key: :user_identities, view: UserIdentityView}
  #   # ], %{}, fn(relationship, relationships) ->
  #   #   if Ecto.assoc_loaded?(Map.get(user, relationship.key)) do
  #   #     Map.put(relationships, relationship.key, %HasMany{
  #   #       serializer: relationship.view,
  #   #       include: true,
  #   #       data: Map.get(user, relationship.key)
  #   #     })
  #   #   else
  #   #     relationships
  #   #   end
  #   # end)
  # end
end
