defmodule ApiWeb.FlagView do
  use ApiWeb, :view
  use JaSerializer.PhoenixView
  alias ApiWeb.{CommentView, PostView, ModerationReportView, UserView}

  attributes [:inserted_at, :text, :bot, :illicit_activity, :trolling, :unconsenting_image, :unmarked_NSFW]

  def preload(record_or_records, _conn, include_opts) do
    Api.Repo.preload(record_or_records, include_opts)
  end

  def relationships(flag, _conn) do
    Enum.reduce([
      %{key: :comment, view: CommentView},
      %{key: :post, view: PostView},
      %{key: :user, view: UserView},
      %{key: :moderation_report, view: ModerationReportView}
    ], %{}, fn(relationship, relationships) ->
      if Ecto.assoc_loaded?(Map.get(flag, relationship.key)) do
        Map.put(relationships, relationship.key, %HasMany{
          serializer: relationship.view,
          include: true,
          data: Map.get(flag, relationship.key)
        })
      else
        relationships
      end
    end)
  end
end
