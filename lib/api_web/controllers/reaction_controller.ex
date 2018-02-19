import Ecto.Query

defmodule ApiWeb.ReactionController do
  use ApiWeb, :controller
  use JaResource # Optionally put in web/web.ex
  plug JaResource

  alias Api.Timeline.Reaction

  def model, do: Reaction

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
