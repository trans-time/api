defmodule ApiWeb.UserTagSummaryView do
  use ApiWeb, :view
  use JaSerializer.PhoenixView
  alias ApiWeb.{UserView, UserTagSummaryTagView, UserTagSummaryUserView}

  attributes [:private_timeline_item_ids]

  def preload(record_or_records, _conn, include_opts) do
    Api.Repo.preload(record_or_records, include_opts)
  end

  def relationships(user, _conn) do
    Enum.reduce([
      %{key: :author, view: UserView},
      %{key: :subject, view: UserView},
      %{key: :user_tag_summary_tags, view: UserTagSummaryTagView},
      %{key: :user_tag_summary_users, view: UserTagSummaryUserView}
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
