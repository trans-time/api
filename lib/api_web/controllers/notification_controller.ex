import Ecto.Query, only: [where: 2]

defmodule ApiWeb.NotificationController do
  use ApiWeb, :controller
  use JaResource # Optionally put in web/web.ex
  plug JaResource
  alias Api.Notifications.Notification

  def model, do: Notification

  def handle_update(conn, record, attributes) do
    handle_request(conn, record.user_id, fn() -> Api.Repo.update(Notification.public_update_changeset(record, attributes)) end)
  end

  defp handle_request(conn, user_id, cb) do
    current_user_id = String.to_integer(Api.Accounts.Guardian.Plug.current_claims(conn)["sub"] || "-1")

    case user_id do
      ^current_user_id -> cb.()
      _ -> {:error, [%{status: "403", source: %{pointer: "/data/relationships/user/data/id"}, title: "remote.errors.title.forbidden", detail: "remote.errors.detail.forbidden.mismatchedTokenAndUserId"}]}
    end
  end

  def filter(_conn, query, "under_moderation", under_moderation) do
    where(query, under_moderation: ^under_moderation)
  end

  def handle_index_query(%{query_params: qp} = conn, query) do
    current_user_id = String.to_integer(Api.Accounts.Guardian.Plug.current_claims(conn)["sub"])
    query = where(query, user_id: ^current_user_id)
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
