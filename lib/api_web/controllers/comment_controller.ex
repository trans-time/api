import Ecto.Query

defmodule ApiWeb.CommentController do
  use ApiWeb, :controller
  use JaResource # Optionally put in web/web.ex
  plug JaResource

  alias Api.Timeline.Comment

  def model, do: Comment

  def filter(_conn, query, "post_id", post_id) do
    where(query, post_id: ^post_id)
  end

  def sort(_conn, query, "inserted_at", inserted_at) do
    order_by(query, [{^inserted_at, :inserted_at}])
  end

  def handle_index_query(%{query_params: qp} = conn, query) do
    current_user_id = String.to_integer(Api.Accounts.Guardian.Plug.current_claims(conn)["sub"] || "-1")

    repo().all(preload_current_user_reaction(conn, query, current_user_id))
  end

  defp preload_current_user_reaction(_conn, query, current_user_id) do
    join(query, :left, [c], r in assoc(c, :reactions), r.user_id == ^current_user_id)
    |> group_by([ti, ..., r], [ti.id, r.id])
    |> preload([..., r], [reactions: r])
  end
end
