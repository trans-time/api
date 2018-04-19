import Ecto.Query

defmodule ApiWeb.ModerationReportController do
  use ApiWeb, :controller
  use JaResource # Optionally put in web/web.ex
  plug JaResource

  alias Api.Accounts.User
  alias Api.Moderation.ModerationReport
  alias ApiWeb.Services.ModerationReportManager

  def model, do: ModerationReport

  def handle_update(conn, record, attributes) do
    handle_request(conn, ModerationReportManager.update(record, attributes))
  end

  defp handle_request(conn, multi) do
    current_user = Api.Repo.get(User, String.to_integer(Api.Accounts.Guardian.Plug.current_claims(conn)["sub"] || "-1"))

    if current_user.is_moderator do
      transaction = Api.Repo.transaction(multi)
      if Kernel.elem(transaction, 0) === :ok, do: Kernel.elem(transaction, 1).moderation_report, else: transaction
    else
      {:error, [%{status: "403", source: %{pointer: "/data/relationships/user/data/isModerator"}, title: "remote.errors.title.forbidden", detail: "remote.errors.detail.forbidden.mustBeModerator"}]}
    end
  end

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
