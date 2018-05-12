import Ecto.Query, only: [where: 2]

defmodule ApiWeb.FollowController do
  use ApiWeb, :controller
  use JaResource # Optionally put in web/web.ex
  plug JaResource

  alias Api.Relationship.Follow

  def model, do: Follow

  def handle_create(conn, attributes) do
    handle_request(conn,  String.to_integer(attributes["follower_id"]), fn() -> Api.Repo.insert(Follow.public_insert_follower_changeset(%Follow{}, attributes)) end)
  end

  def handle_delete(conn, record) do
    handle_request(conn, record.follower_id, fn() -> Api.Repo.delete(record) end)
  end

  def handle_update(conn, record, attributes) do
    current_user_id = String.to_integer(Api.Accounts.Guardian.Plug.current_claims(conn)["sub"] || "-1")

    if (current_user_id == record.follower_id) do
      handle_request(conn, record.follower_id, fn() -> Api.Repo.update(Follow.public_update_follower_changeset(record, attributes)) end)
    else
      handle_request(conn, record.followed_id, fn() -> Api.Repo.update(Follow.public_update_followed_changeset(record, attributes)) end)
    end
  end

  defp handle_request(conn, user_id, cb) do
    current_user_id = String.to_integer(Api.Accounts.Guardian.Plug.current_claims(conn)["sub"] || "-1")

    case user_id do
      ^current_user_id -> cb.()
      _ -> {:error, [%{status: "403", source: %{pointer: "/data/relationships/user/data/id"}, title: "remote.errors.title.forbidden", detail: "remote.errors.detail.forbidden.mismatchedTokenAndUserId"}]}
    end
  end

  def filter(_conn, query, "followed_id", followed_id) do
    where(query, followed_id: ^followed_id)
  end

  def filter(_conn, query, "follower_id", follower_id) do
    where(query, follower_id: ^follower_id)
  end

  def handle_index_query(%{query_params: qp}, query) do
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
