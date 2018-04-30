import Ecto.Query

defmodule ApiWeb.Services.ReactionManager do
  alias Api.Timeline.{Comment, TimelineItem, Reaction}
  alias Ecto.Multi

  def delete(record) do
    Multi.new
    |> Multi.update_all(:reactable, get_reactable(record), inc: inc(record, -1))
    |> Multi.delete(:reaction, record)
  end

  def insert(attributes) do
    changeset = Reaction.changeset(%Reaction{}, attributes)

    Multi.new
    |> Multi.update_all(:reactable, get_reactable(attributes), inc: inc(attributes, 1))
    |> Multi.insert(:reaction, changeset)
  end

  def update(record, attributes) do
    changeset = Reaction.changeset(record, attributes)

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
end
