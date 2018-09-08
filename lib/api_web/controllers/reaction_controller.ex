import Ecto.Query

defmodule ApiWeb.ReactionController do
  use ApiWeb, :controller
  use JaResource # Optionally put in web/web.ex
  plug JaResource

  alias Api.Timeline.Reaction
  alias ApiWeb.Services.ReactionManager

  def model, do: Reaction

  def handle_create(conn, attributes) do
    handle_request(conn, String.to_integer(attributes["user_id"]), ReactionManager.insert(attributes))
  end

  def handle_delete(conn, record) do
    handle_request(conn, record.user_id, ReactionManager.delete(record))
  end

  def handle_update(conn, record, attributes) do
    handle_request(conn, record.user_id, ReactionManager.update(record, attributes))
  end

  defp handle_request(conn, user_id, multi) do
    current_user_id = String.to_integer(Api.Accounts.Guardian.Plug.current_claims(conn)["sub"] || "-1")

    case user_id do
      ^current_user_id ->
        transaction = Api.Repo.transaction(multi)
        if Kernel.elem(transaction, 0) === :ok, do: Kernel.elem(transaction, 1).reaction, else: transaction
      _ -> {:error, [%{status: "403", source: %{pointer: "/data/relationships/user/data/id"}, title: "remote.errors.title.forbidden", detail: "remote.errors.detail.forbidden.mismatchedTokenAndUserId"}]}
    end
  end

  def filter(_conn, query, "comment_id", comment_id) do
    where(query, comment_id: ^comment_id)
  end

  def filter(_conn, query, "timeline_item_id", timeline_item_id) do
    where(query, timeline_item_id: ^timeline_item_id)
  end

  def sort(_conn, query, "inserted_at", direction) do
    order_by(query, [{^direction, :inserted_at}])
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
