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
    having([ti, ..., tit], fragment("? <@ array_agg(?)", ^tag_ids, tit.tag_id))
  end

  def filter(_conn, query, "user_ids", user_ids) do
    user_ids = Enum.map(user_ids, fn(x) -> String.to_integer(x) end)
    join(query, :inner, [ti], tiu in "timeline_items_users", tiu.timeline_item_id == ti.id and tiu.user_id in ^user_ids) |>
    group_by([ti], ti.id) |>
    having([ti, ..., tiu], fragment("? <@ array_agg(?)", ^user_ids, tiu.user_id))
  end

  def filter(conn, query, "follower_id", follower_id) do
    if (Api.Accounts.Guardian.Plug.current_claims(conn)["sub"] === follower_id) do
      join(query, :inner, [ti], f in "follows", f.follower_id == ^String.to_integer(follower_id) and ti.user_id == f.followed_id) |>
        group_by([ti], ti.id)
    else
      query
    end
  end

  def filter(_conn, query, "query", query_string) do
    Enum.reduce(String.split(query_string), query, fn(query_part, query) ->
      query_type = case String.at(query_part, 0) do
        "*" -> :identity
        "#" -> :tag
        "@" -> :user
        _ -> :generic
      end

      main_query = String.downcase(if (query_type == :generic), do: query_part, else: String.slice(query_part, 1..-1))

      case query_type do
        :identity ->
          join(query, :inner, [ti], u in "users", ti.user_id == u.id) |>
            join(:inner, [ti, ..., u], ui in "user_identities", ui.user_id == u.id) |>
            join(:inner, [ti, ..., ui], i in "identities", ui.identity_id == i.id) |>
            group_by([ti, ..., i], [ti.id, i.name]) |>
            having([ti, ..., i], fragment("lower(?)", i.name) == ^main_query)
        :user ->
          join(query, :inner, [ti], u in "users", ti.user_id == u.id and fragment("lower(?)", u.username) == ^main_query) |>
            group_by([ti], ti.id)
        _ ->
          join(query, :inner, [ti], tit in "timeline_items_tags", tit.timeline_item_id == ti.id) |>
            join(:inner, [ti, ..., tit], t in "tags", tit.tag_id == t.id) |>
            group_by([ti, ..., t], [ti.id, t.name]) |>
            having([ti, ..., t], fragment("lower(?)", t.name) == ^main_query)
      end
    end)
  end

  def sort(_conn, query, "date", direction) do
    order_by(query, [{^direction, :date}])
  end

  def handle_index_query(%{query_params: qp} = conn, query) do
    query = filter_deleted(conn, query)
    query = filter_under_moderation(conn, query)
    query = filter_private(conn, query)
    query = filter_blocked(conn, query)
    [limit, offset] = get_limit_and_offset(qp, query)

    repo().all(query |> limit(^limit) |> offset(^offset))
  end

  def filter_deleted(_conn, query) do
    where(query, deleted: ^false)
  end

  def filter_under_moderation(conn, query) do
    current_user_id = String.to_integer(Api.Accounts.Guardian.Plug.current_claims(conn)["sub"])
    where(query, under_moderation: ^false) |>
      or_where(user_id: ^current_user_id)
  end

  def filter_private(conn, query) do
    current_user_id = String.to_integer(Api.Accounts.Guardian.Plug.current_claims(conn)["sub"])
    where(query, [ti], ti.private == ^false or fragment("exists(select 1 from follows f where f.follower_id = ? and f.followed_id = ? and f.can_view_private = true)", ^current_user_id, ti.user_id))
  end

  def filter_blocked(conn, query) do
    current_user_id = String.to_integer(Api.Accounts.Guardian.Plug.current_claims(conn)["sub"])
    where(query, [ti], fragment("not exists(select 1 from blocks b where b.blocked_id = ? and b.blocker_id = ?)", ^current_user_id, ti.user_id))
  end

  def get_limit_and_offset(qp, query) do
    limit = String.to_integer(qp["page_size"])
    from_id = qp["from_timeline_item_id"]
    should_progress = qp["should_progress"]

    if from_id && byte_size(from_id) > 0 do
      order = "ORDER BY date DESC"
      offset = List.first(repo().all(
        from e in subquery(
          from t in query,
            select: %{id: t.id, rn: fragment("row_number() OVER(ORDER BY date DESC)")}
        ),
          where: e.id == ^String.to_integer(from_id),
          select: e.rn
      )) || 0

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
