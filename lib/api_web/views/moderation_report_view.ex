defmodule ApiWeb.ModerationReportView do
  use ApiWeb, :view
  use JaSerializer.PhoenixView
  alias ApiWeb.{CommentView, TimelineItemView, FlagView, UserView, VerdictView}

  attributes [:inserted_at, :was_violation, :resolved]

  def preload(record_or_records, _conn, include_opts) do
    Api.Repo.preload(record_or_records, include_opts)
  end

  def relationships(flag, _conn) do
    Enum.reduce([
      %{key: :comment, view: CommentView},
      %{key: :timeline_item, view: TimelineItemView},
      %{key: :indicted, view: UserView},
      %{key: :verdicts, view: VerdictView},
      %{key: :flags, view: FlagView}
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
