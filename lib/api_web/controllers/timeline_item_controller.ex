import Ecto.Query

defmodule ApiWeb.TimelineItemController do
  use ApiWeb, :controller
  use JaResource # Optionally put in web/web.ex
  plug JaResource

  def model, do: Api.Timeline.TimelineItem

  def handle_index_query(%{query_params: qp}, query) do
    [limit, offset] = get_limit_and_offset(qp, query)
  
    repo().all(query |> limit(^limit) |> offset(^offset))
  end

  def get_limit_and_offset(qp, query) do
    from_id = qp["from_timeline_item_id"]
    should_progress = qp["should_progress"]
    limit = String.to_integer(qp["page_size"])

    if from_id do
      [offset | tail] = repo().all(
        from e in subquery(
          from t in query,
            select: %{id: t.id, rn: fragment("row_number() OVER()")}
        ),
          where: e.id == ^String.to_integer(from_id),
          select: e.rn
      )

      cond do
        qp["should_progress"] && String.to_existing_atom(qp["should_progress"]) ->
          [limit, offset = max(0, offset - limit)]
        qp["initial_query"] && String.to_existing_atom(qp["initial_query"]) ->
          [limit *2, max(0, offset - limit)]
        true ->
          [limit, offset - 1]
      end
    else
      if qp["last_timeline_item"] do
        [limit, max(0, Api.Repo.aggregate(query, :count, :id) - limit)]
      else
        [limit, 0]
      end
    end
  end
end
