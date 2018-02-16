import Ecto.Query

defmodule ApiWeb.ReactionController do
  use ApiWeb, :controller
  use JaResource # Optionally put in web/web.ex
  plug JaResource

  alias Api.Timeline.Reaction

  def records(conn) do
    table_name = Inflex.pluralize(conn.params["filter"]["reactable_type"]) <> "_reactions"

    from r in {table_name, Reaction}
  end

  def filter(_conn, query, "reactable_id", reactable_id) do
    where(query, reactable_id: ^reactable_id)
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
