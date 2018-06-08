defmodule ApiWeb.FollowView do
  use ApiWeb, :view
  use JaSerializer.PhoenixView
  alias ApiWeb.{UserView}

  attributes [:can_view_private, :has_requested_private]

  def preload(record_or_records, _conn, include_opts) do
    Api.Repo.preload(record_or_records, include_opts)
  end

  def relationships(user, _conn) do
    Enum.reduce([
      %{key: :followed, view: UserView},
      %{key: :follower, view: UserView}
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
