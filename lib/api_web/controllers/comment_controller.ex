import Ecto.Query

defmodule ApiWeb.CommentController do
  use ApiWeb, :controller
  use JaResource # Optionally put in web/web.ex
  plug JaResource

  alias Api.Timeline.Comment
  alias ApiWeb.Services.CommentManager

  def model, do: Comment

  def handle_create(conn, attributes) do
    handle_request(conn, String.to_integer(attributes["user_id"]), CommentManager.insert(attributes, Api.Accounts.Guardian.Plug.current_resource(conn)))
  end

  def handle_delete(conn, record) do
    handle_request(conn, record.user_id, CommentManager.delete(record, %{is_marked_for_deletion_by_user: true}))
  end

  def handle_update(conn, record, attributes) do
    handle_request(conn, record.user_id, CommentManager.update(record, attributes))
  end

  defp handle_request(conn, user_id, multi) do
    current_user_id = String.to_integer(Api.Accounts.Guardian.Plug.current_claims(conn)["sub"] || "-1")

    case user_id do
      ^current_user_id ->
        transaction = Api.Repo.transaction(multi)
        if Kernel.elem(transaction, 0) === :ok, do: Kernel.elem(transaction, 1).comment, else: transaction
      _ -> {:error, [%{status: "403", source: %{pointer: "/data/relationships/user/data/id"}, title: "remote.errors.title.forbidden", detail: "remote.errors.detail.forbidden.mismatchedTokenAndUserId"}]}
    end
  end

  def filter(conn, query, "timeline_item_id", timeline_item_id) do
    current_user_id = String.to_integer(Api.Accounts.Guardian.Plug.current_claims(conn)["sub"] || "-1")

    timeline_item = Api.Repo.get(Api.Timeline.TimelineItem, timeline_item_id)

    if timeline_item.user_id !== current_user_id do
      query = filter_blocked(conn, query, current_user_id)
    end

    where(query, timeline_item_id: ^timeline_item_id)
  end

  def filter(_conn, query, "is_marked_for_deletion", is_marked_for_deletion) do
    where(query, is_marked_for_deletion: ^is_marked_for_deletion)
  end

  def filter(conn, query, "is_under_moderation", is_under_moderation) do
    current_user_id = String.to_integer(Api.Accounts.Guardian.Plug.current_claims(conn)["sub"] || "-1")
    where(query, [ti], ti.is_under_moderation == ^is_under_moderation or ti.user_id == ^current_user_id)
  end

  def sort(_conn, query, "inserted_at", inserted_at) do
    order_by(query, [{^inserted_at, :inserted_at}])
  end

  def handle_index_query(%{query_params: qp} = conn, query) do
    current_user_id = String.to_integer(Api.Accounts.Guardian.Plug.current_claims(conn)["sub"] || "-1")
    query = if current_user_id == -1, do: hide_private_accounts(conn, query), else: query

    repo().all(preload_current_user_reaction(conn, query, current_user_id))
  end

  def handle_show(conn, id) do
    current_user_id = String.to_integer(Api.Accounts.Guardian.Plug.current_claims(conn)["sub"] || "-1")

    if (current_user_id == -1) do
      query = Comment
      |> where([c], c.id == ^id)
      |> join(:inner, [c], ti in assoc(c, :timeline_item), c.timeline_item_id == ti.id)
      |> join(:inner, [c, ti], u in assoc(ti, :user), u.is_public == ^true)
      |> group_by([c], [c.id])
      repo().one(query)
    else
      repo().get(Comment, id)
    end
  end

  def hide_private_accounts(_conn, query) do
    query
    |> join(:inner, [c], u in assoc(c, :user), u.is_public == ^true)
    |> group_by([c], [c.id])
  end

  defp filter_blocked(_conn, query, current_user_id) do
    where(query, [c], fragment("not exists(select 1 from blocks b where b.blocked_id = ? and b.blocker_id = ?)", ^current_user_id, c.user_id))
  end

  defp preload_current_user_reaction(_conn, query, current_user_id) do
    join(query, :left, [c], r in assoc(c, :reactions), r.user_id == ^current_user_id)
    |> group_by([ti, ..., r], [ti.id, r.id])
    |> preload([..., r], [reactions: r])
  end
end
