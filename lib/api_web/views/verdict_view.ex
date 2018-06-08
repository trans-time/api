defmodule ApiWeb.VerdictView do
  use ApiWeb, :view
  use JaSerializer.PhoenixView
  alias ApiWeb.{ModerationReportView, UserView}

  attributes [
    :inserted_at, :moderator_comment, :was_violation,
    :action_banned_user, :action_mark_flaggable_for_deletion, :action_ignore_flags, :action_lock_comments,
    :action_change_maturity_rating,
    :action_mark_images_for_deletion, :delete_image_ids,
    :ban_user_until, :lock_comments_until
  ]

  def preload(record_or_records, _conn, include_opts) do
    Api.Repo.preload(record_or_records, include_opts)
  end

  def relationships(flag, _conn) do
    Enum.reduce([
      %{key: :moderator, view: UserView},
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
