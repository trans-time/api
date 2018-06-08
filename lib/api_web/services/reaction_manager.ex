import Ecto.Query

defmodule ApiWeb.Services.ReactionManager do
  alias Api.Timeline.{Comment, TimelineItem, Reaction}
  alias ApiWeb.Services.Notifications.{NotificationCommentReactionManager, NotificationTimelineItemReactionManager}
  alias Ecto.Multi

  def delete(record) do
    Multi.new
    |> Multi.update_all(:reactable, get_reactable(record), inc: inc(record, -1) ++ [reaction_count: -1])
    |> Multi.delete(:reaction, record)
  end

  def insert(attributes) do
    changeset = Reaction.public_insert_changeset(%Reaction{}, attributes)

    Multi.new
    |> Multi.update_all(:reactable, get_reactable(attributes), [inc: inc(attributes, 1) ++ [reaction_count: 1]], returning: true)
    |> Multi.insert(:reaction, changeset)
    |> Multi.merge(fn %{reactable: {_, [reactable | _]}} ->
      merge_notification(reactable)
    end)
  end

  def update(record, attributes) do
    changeset = Reaction.public_update_changeset(record, attributes)

    Multi.new
    |> Multi.update_all(:reactable, get_reactable(attributes), inc: inc(attributes, 1) ++ inc(record, -1))
    |> Multi.update(:reaction, changeset)
  end

  defp get_reactable(reaction) do
    indifferent_reaction = Indifferent.access(reaction)

    cond do
      indifferent_reaction[:timeline_item_id] -> TimelineItem |> where(id: ^indifferent_reaction[:timeline_item_id])
      indifferent_reaction[:comment_id] -> Comment |> where(id: ^indifferent_reaction[:comment_id])
    end
  end

  defp inc(reaction, amount) do
    case Indifferent.access(reaction)[:reaction_type] do
      1 -> [star_count: amount]
      2 -> [sun_count: amount]
      3 -> [moon_count: amount]
    end
  end

  defp merge_notification(%TimelineItem{} = timeline_item) do
    NotificationTimelineItemReactionManager.insert(timeline_item)
  end

  defp merge_notification(%Comment{} = comment) do
    NotificationCommentReactionManager.insert(comment)
  end
end
