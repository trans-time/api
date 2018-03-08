defmodule ApiWeb.UserProfileView do
  use ApiWeb, :view
  use JaSerializer.PhoenixView
  alias ApiWeb.{UserTagSummaryView, UserView}

  attributes [:description, :post_count, :website]

  has_one :user_tag_summary,
    serializer: UserTagSummaryView

  def relationships(user, _conn) do
    Enum.reduce([
      %{key: :user_tag_summary, view: UserTagSummaryView}
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
