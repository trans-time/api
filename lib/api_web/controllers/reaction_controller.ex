import Ecto.Query

defmodule ApiWeb.ReactionController do
  use ApiWeb, :controller
  use JaResource # Optionally put in web/web.ex
  plug JaResource

  alias Api.Timeline.Reaction

  def model, do: Reaction

  def handle_create(conn, attributes) do
    current_user_id = Api.Accounts.Guardian.Plug.current_claims(conn)["sub"]
  
    case attributes["user_id"] do
      ^current_user_id -> Reaction.changeset(%Reaction{}, attributes)
      _ -> {:error, [%{status: "403", source: %{pointer: "/data/relationships/user/data/id"}, title: "remote.errors.title.forbidden", detail: "remote.errors.detail.forbidden.mismatchedTokenAndUserId"}]}
    end
  end

  def handle_delete(conn, record) do
    current_user_id = String.to_integer(Api.Accounts.Guardian.Plug.current_claims(conn)["sub"])

    case record.user_id do
      ^current_user_id -> super(conn, record)
      _ -> {:error, [%{status: "403", source: %{pointer: "/data/relationships/user/data/id"}, title: "remote.errors.title.forbidden", detail: "remote.errors.detail.forbidden.mismatchedTokenAndUserId"}]}
    end
  end

  def handle_update(conn, record, attributes) do
    current_user_id = String.to_integer(Api.Accounts.Guardian.Plug.current_claims(conn)["sub"])

    case record.user_id do
      ^current_user_id -> Reaction.changeset(record, attributes)
      _ -> {:error, [%{status: "403", source: %{pointer: "/data/relationships/user/data/id"}, title: "remote.errors.title.forbidden", detail: "remote.errors.detail.forbidden.mismatchedTokenAndUserId"}]}
    end
  end

  def filter(_conn, query, "comment_id", comment_id) do
    where(query, comment_id: ^comment_id)
  end

  def filter(_conn, query, "post_id", post_id) do
    where(query, post_id: ^post_id)
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
