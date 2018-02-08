import Ecto.Query

defmodule ApiWeb.TimelineItemController do
  use ApiWeb, :controller
  use JaResource # Optionally put in web/web.ex
  plug JaResource

  alias Api.Timeline.TimelineItem

  def model, do: TimelineItem

  def filter(_conn, query, "user_id", user_id) do
    where(query, user_id: ^user_id)
  end

  def filter(_conn, query, "tag_ids", tag_ids) do
    tag_ids = Enum.map(tag_ids, fn(x) -> String.to_integer(x) end)
    join(query, :inner, [ti], tit in "timeline_items_tags", tit.timeline_item_id == ti.id and tit.tag_id in ^tag_ids) |>
    group_by([ti], ti.id) |>
    having([ti, tit], fragment("? <@ array_agg(?)", ^tag_ids, tit.tag_id))
  end

  def filter(_conn, query, "user_ids", user_ids) do
    user_ids = Enum.map(user_ids, fn(x) -> String.to_integer(x) end)
    join(query, :inner, [ti], tis in "timeline_items_users", tis.timeline_item_id == ti.id and tis.user_id in ^user_ids) |>
    group_by([ti], ti.id) |>
    having([ti, tis], fragment("? <@ array_agg(?)", ^user_ids, tis.user_id))
  end

  def sort(_conn, query, "date", direction) do
    order_by(query, [{^direction, :date}])
  end

  def handle_index_query(%{query_params: qp}, query) do
    [limit, offset] = get_limit_and_offset(qp, query)

    repo().all(query |> limit(^limit) |> offset(^offset))
  end

  def get_limit_and_offset(qp, query) do
    limit = String.to_integer(qp["page_size"])
    from_id = qp["from_timeline_item_id"]
    should_progress = qp["should_progress"]

    if from_id && byte_size(from_id) > 0 do
      order = "ORDER BY date DESC"
      [offset | tail] = repo().all(
        from e in subquery(
          from t in query,
            select: %{id: t.id, rn: fragment("row_number() OVER(ORDER BY date DESC)")}
        ),
          where: e.id == ^String.to_integer(from_id),
          select: e.rn
      )

      cond do
        qp["initial_query"] && String.to_existing_atom(qp["initial_query"]) ->
          offset = offset - div(limit, 2)
        qp["should_progress"] && String.to_existing_atom(qp["should_progress"]) ->
          offset = offset - (limit + 1)
        true ->
          offset
      end

      if offset < 0 do
        limit = limit + offset
        offset = 0
      end

      [limit, offset]
    else
      if qp["last_timeline_item"] do
        [limit, max(0, Api.Repo.aggregate(query, :count, :id) - limit)]
      else
        [limit, 0]
      end
    end
  end
end
