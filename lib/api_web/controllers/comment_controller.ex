import Ecto.Query

defmodule ApiWeb.CommentController do
  use ApiWeb, :controller
  use JaResource # Optionally put in web/web.ex
  plug JaResource

  alias Api.Timeline.Comment

  def model, do: Comment

  # def records(conn) do
  #   table_name = Inflex.pluralize(conn.params["filter"]["commentable_type"]) <> "_comments"
  #
  #   from r in {table_name, Comment}
  # end

  def filter(_conn, query, "post_id", post_id) do
    where(query, post_id: ^post_id)
  end

  # def handle_index_query(%{query_params: qp}, query) do
  #   repo().paginate(query, qp)
  # end
  #
  # def serialization_opts(_conn, params, models) do
  #   %{
  #     include: params["include"],
  #     meta: %{
  #       total_pages: models.total_pages
  #     }
  #   }
  # end
end
