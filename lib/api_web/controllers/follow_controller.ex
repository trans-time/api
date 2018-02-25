import Ecto.Query, only: [where: 2]

defmodule ApiWeb.FollowController do
  use ApiWeb, :controller
  use JaResource # Optionally put in web/web.ex
  plug JaResource

  alias Api.Relationship.Follow

  def model, do: Follow

  def handle_create(conn, attributes) do
    current_user_id = Api.Accounts.Guardian.Plug.current_claims(conn)["sub"]

    case attributes["follower_id"] do
      ^current_user_id -> Follow.changeset(%Follow{}, attributes)
      _ -> {:error, [%{status: "403", source: %{pointer: "/data/relationships/follower/data/id"}, title: "remote.errors.title.forbidden", detail: "remote.errors.detail.forbidden.mismatchedTokenAndUserId"}]}
    end
  end

  def handle_delete(conn, record) do
    current_user_id = String.to_integer(Api.Accounts.Guardian.Plug.current_claims(conn)["sub"])

    case record.follower_id do
      ^current_user_id -> super(conn, record)
      _ -> {:error, [%{status: "403", source: %{pointer: "/data/relationships/follower/data/id"}, title: "remote.errors.title.forbidden", detail: "remote.errors.detail.forbidden.mismatchedTokenAndUserId"}]}
    end
  end

  def handle_update(conn, record, attributes) do
    current_user_id = String.to_integer(Api.Accounts.Guardian.Plug.current_claims(conn)["sub"])

    case record.follower_id do
      ^current_user_id -> Follow.changeset(record, attributes)
      _ -> {:error, [%{status: "403", source: %{pointer: "/data/relationships/follower/data/id"}, title: "remote.errors.title.forbidden", detail: "remote.errors.detail.forbidden.mismatchedTokenAndUserId"}]}
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
