import Ecto.Query

defmodule ApiWeb.TimelineItemController do
  use ApiWeb, :controller
  use JaResource # Optionally put in web/web.ex
  plug JaResource

  alias Api.Timeline.Reaction
  alias Api.Timeline.TimelineItem

  def model, do: TimelineItem

  def filter(conn, query, "blocked", blocked) do
    if blocked do
      current_user_id = String.to_integer(Api.Accounts.Guardian.Plug.current_claims(conn)["sub"] || "-1")
      where(query, [ti], fragment("not exists(select 1 from blocks b where b.blocked_id = ? and b.blocker_id = ?)", ^current_user_id, ti.user_id))
    else
      query
    end
  end

  def filter(_conn, query, "deleted", deleted) do
    where(query, deleted: ^deleted)
  end

  def filter(conn, query, "follower_id", follower_id) do
    if (Api.Accounts.Guardian.Plug.current_claims(conn)["sub"] === follower_id) do
      join(query, :inner, [ti], f in "follows", f.follower_id == ^String.to_integer(follower_id) and ti.user_id == f.followed_id)
      |> group_by([ti], ti.id)
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
          join(query, :inner, [ti], u in "users", ti.user_id == u.id)
          |> join(:inner, [..., u], ui in "user_identities", ui.user_id == u.id)
          |> join(:inner, [..., ui], i in "identities", ui.identity_id == i.id)
          |> group_by([ti, ..., i], [ti.id, i.name])
          |> having([..., i], i.name == ^main_query)
        :user ->
          join(query, :inner, [ti], u in "users", ti.user_id == u.id and u.username == ^main_query)
          |> group_by([ti], ti.id)
        _ ->
          join(query, :inner, [ti], tit in "timeline_items_tags", tit.timeline_item_id == ti.id)
          |> join(:inner, [..., tit], t in "tags", tit.tag_id == t.id)
          |> group_by([ti, ..., t], [ti.id, t.name])
          |> having([..., t], t.name == ^main_query)
      end
    end)
  end

  def filter(conn, query, "private", private) do
    current_user_id = String.to_integer(Api.Accounts.Guardian.Plug.current_claims(conn)["sub"] || "-1")
    where(query, [ti], ti.private == ^private or ti.user_id == ^current_user_id or fragment("exists(select 1 from follows f where f.follower_id = ? and f.followed_id = ? and f.can_view_private = true)", ^current_user_id, ti.user_id))
  end

  def filter(_conn, query, "refresh_ids", refresh_ids) do
    refresh_ids = Enum.map(refresh_ids, fn(x) -> String.to_integer(x) end)
    where(query, [ti], ti.id in ^refresh_ids)
  end

  def filter(_conn, query, "tag_names", tag_names) do
    # TODO: Which is faster?
    # join(query, :inner, [], t in "tags", t.name in ^tag_names)
    # |> join(:inner, [ti, ..., t], tit in "timeline_items_tags", tit.timeline_item_id == ti.id)
    # |> group_by([ti], ti.id)
    # |> having([..., t, tit], fragment("array_agg(?) <@ array_agg(?)", t.id, tit.tag_id))

    Enum.reduce(tag_names, query, fn(name, query) ->
      join(query, :inner, [ti], tit in "timeline_items_tags", tit.timeline_item_id == ti.id)
      |> join(:inner, [..., tit], t in "tags", tit.tag_id == t.id)
      |> group_by([ti, ..., t], [ti.id, t.name])
      |> having([..., t], t.name == ^name)
    end)
  end

  def filter(conn, query, "under_moderation", under_moderation) do
    current_user_id = String.to_integer(Api.Accounts.Guardian.Plug.current_claims(conn)["sub"] || "-1")
    where(query, [ti], ti.under_moderation == ^under_moderation or ti.user_id == ^current_user_id)
  end

  def filter(conn, query, "user_id", user_id) do
    if (conn.query_params["filter"]["user_usernames"] == nil || Kernel.length(conn.query_params["filter"]["user_usernames"]) == 0) do
      where(query, user_id: ^user_id)
    else
      # TODO: Which is faster?
      # join(query, :inner, [], u in "users", u.username in ^conn.query_params["filter"]["user_usernames"])
      # |> join(:inner, [ti], tiu in "timeline_items_users", tiu.timeline_item_id == ti.id)
      # |> group_by([ti], ti.id)
      # |> having([..., u, tiu], fragment("array_agg(?) <@ array_agg(?)", u.id, tiu.user_id))

      Enum.reduce(conn.query_params["filter"]["user_usernames"], query, fn(username, query) ->
        join(query, :inner, [ti], tiu in "timeline_items_users", tiu.timeline_item_id == ti.id)
        |> join(:inner, [..., tiu], u in "users", tiu.user_id == u.id)
        |> group_by([ti, ..., u], [ti.id, u.username])
        |> having([..., u], u.username == ^username)
      end)
    end
  end

  def sort(_conn, query, "date", direction) do
    order_by(query, [{^direction, :date}])
  end

  def handle_index_query(%{query_params: qp} = conn, query) do
    current_user_id = String.to_integer(Api.Accounts.Guardian.Plug.current_claims(conn)["sub"] || "-1")

    [limit, offset] = get_limit_and_offset(qp, query)

    query = query |> limit(^limit) |> offset(^offset)

    query = preload_current_user_reaction(conn, query, current_user_id)

    repo().all(query)
  end

  def preload_current_user_reaction(_conn, query, current_user_id) do
    join(query, :left, [ti], p in assoc(ti, :post))
    |> join(:left, [..., p], r in assoc(p, :reactions), r.user_id == ^current_user_id)
    |> group_by([ti, ..., p, r], [ti.id, p.id, r.id])
    |> preload([..., p, r], [post: {p, reactions: r}])
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
