import Ecto.Query

defmodule ApiWeb.Services.TimelineItemManager do
  alias Api.Moderation.TextVersion
  alias Api.Accounts.User
  alias Api.Profile.{UserProfile, UserTagSummary, UserTagSummaryTag, UserTagSummaryUser}
  alias Api.Timeline.{Tag, TimelineItem}
  alias ApiWeb.Services.Libra
  alias Ecto.Multi

  def delete(timeline_item, attributes) do
    timeline_item_changeset = TimelineItem.private_changeset(timeline_item, Map.merge(%{deleted: true}, attributes))

    Multi.new
    |> Multi.update_all(:user_profile, UserProfile |> where(user_id: ^timeline_item.user_id), inc: [post_count: -1])
    |> Multi.update(:timeline_item, timeline_item_changeset)
  end

  def undelete(timeline_item, attributes) do
    timeline_item_changeset = TimelineItem.private_changeset(timeline_item, attributes)

    Multi.new
    |> Multi.update_all(:user_profile, UserProfile |> where(user_id: ^timeline_item.user_id), inc: [post_count: 1])
    |> Multi.update(:timeline_item, timeline_item_changeset)
  end
end
