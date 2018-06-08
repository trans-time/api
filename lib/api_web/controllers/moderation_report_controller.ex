import Ecto.Query

defmodule ApiWeb.ModerationReportController do
  use ApiWeb, :controller
  use JaResource # Optionally put in web/web.ex
  plug JaResource

  alias Api.Accounts.User
  alias Api.Moderation.ModerationReport

  def model, do: ModerationReport

  def sort(_conn, query, "is_resolved", direction) do
    order_by(query, [{^direction, :is_resolved}])
  end

  def filter(_conn, query, "should_ignore", should_ignore) do
    where(query, should_ignore: ^should_ignore)
  end

  def filter(conn, query, "indicted_id", indicted_id) do
    current_user_id = Api.Accounts.Guardian.Plug.current_claims(conn)["sub"] || "-1"
    if current_user_id == indicted_id, do: where(query, indicted_id: ^indicted_id, was_violation: ^true), else: query
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
