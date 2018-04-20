import Ecto.Query

defmodule ApiWeb.ModerationReportController do
  use ApiWeb, :controller
  use JaResource # Optionally put in web/web.ex
  plug JaResource

  alias Api.Accounts.User
  alias Api.Moderation.ModerationReport

  def model, do: ModerationReport

  def sort(_conn, query, "resolved", direction) do
    order_by(query, [{^direction, :resolved}])
  end

  def handle_index_query(%{query_params: qp}, query) do
    repo().paginate(query, qp)
  end

  def serialization_opts(_conn, params, %Scrivener.Page{} = models) do
    %{
      include: params["include"],
      meta: %{
        total_pages: models.total_pages
      }
    }
  end

  def serialization_opts(conn, params, models) do
    super(conn, params, models)
  end
end
