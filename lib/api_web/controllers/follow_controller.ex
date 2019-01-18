import Ecto.Query

defmodule ApiWeb.FollowController do
  use ApiWeb, :controller
  use JaResource # Optionally put in web/web.ex
  plug JaResource
  alias ApiWeb.Services.FollowManager

  alias Api.Relationship.Follow

  def model, do: Follow

  def handle_create(conn, attributes) do
    handle_request(conn,  String.to_integer(attributes["follower_id"]), FollowManager.insert(attributes))
  end

  def handle_delete(conn, record) do
    handle_request(conn, record.follower_id, FollowManager.delete(record))
  end

  def handle_update(conn, record, attributes) do
    current_user_id = String.to_integer(Api.Accounts.Guardian.Plug.current_claims(conn)["sub"] || "-1")
    user_id = if record.followed_id == current_user_id, do: record.followed_id, else: record.follower_id

    handle_request(conn, user_id, FollowManager.update(current_user_id == record.follower_id, record, attributes))
  end

  defp handle_request(conn, user_id, multi) do
    current_user_id = String.to_integer(Api.Accounts.Guardian.Plug.current_claims(conn)["sub"] || "-1")

    case user_id do
      ^current_user_id ->
        transaction = Api.Repo.transaction(multi)
        if Kernel.elem(transaction, 0) === :ok, do: Kernel.elem(transaction, 1).follow, else: transaction
      _ -> {:error, [%{status: "403", source: %{pointer: "/data/relationships/user/data/id"}, title: "remote.errors.title.forbidden", detail: "remote.errors.detail.forbidden.mismatchedTokenAndUserId"}]}
    end
  end

  def hide_private_accounts(_conn, query) do
    query
    |> join(:inner, [f], u in assoc(f, :followed), u.is_public == ^true)
    |> join(:inner, [f], u in assoc(f, :follower), u.is_public == ^true)
    |> group_by([ti], [ti.id])
  end

  def filter(_conn, query, "followed_id", followed_id) do
    where(query, followed_id: ^followed_id)
  end

  def filter(_conn, query, "follower_id", follower_id) do
    where(query, follower_id: ^follower_id)
  end

  def sort(_conn, query, "inserted_at", direction) do
    order_by(query, [{^direction, :inserted_at}])
  end

  def sort(_conn, query, "has_requested_private", direction) do
    order_by(query, [{^direction, :has_requested_private}])
  end

  def handle_index_query(%{query_params: qp} = conn, query) do
    current_user_id = String.to_integer(Api.Accounts.Guardian.Plug.current_claims(conn)["sub"] || "-1")
    query = if current_user_id == -1, do: hide_private_accounts(conn, query), else: query

    repo().paginate(query, qp)
  end

  def serialization_opts(_conn, params, models) do
    %{
      include: params["include"],
      meta: %{
        total_pages: models.total_pages
      }
    }
  end
end
