import Ecto.Query, only: [where: 2]

defmodule ApiWeb.FlagController do
  use ApiWeb, :controller
  use JaResource # Optionally put in web/web.ex
  plug JaResource
  alias ApiWeb.Services.FlagManager

  def model, do: Api.Moderation.Flag

  def handle_create(conn, attributes) do
    handle_request(conn, String.to_integer(attributes["user_id"]), FlagManager.insert(attributes))
  end

  defp handle_request(conn, user_id, multi) do
    current_user_id = String.to_integer(Api.Accounts.Guardian.Plug.current_claims(conn)["sub"] || "-1")

    case user_id do
      ^current_user_id ->
        transaction = Api.Repo.transaction(multi)
        if Kernel.elem(transaction, 0) === :ok, do: Kernel.elem(transaction, 1).flag, else: transaction
      _ -> {:error, [%{status: "403", source: %{pointer: "/data/relationships/user/data/id"}, title: "remote.errors.title.forbidden", detail: "remote.errors.detail.forbidden.mismatchedTokenAndUserId"}]}
    end
  end

  def handle_show(conn, id) do
    current_user_id = String.to_integer(Api.Accounts.Guardian.Plug.current_claims(conn)["sub"] || "-1")
    flag = Api.Repo.get(Api.Moderation.Flag, id)

    case flag.user_id do
      ^current_user_id -> flag
      _ -> {:error, [%{status: "403", source: %{pointer: "/data/relationships/user/data/id"}, title: "remote.errors.title.forbidden", detail: "remote.errors.detail.forbidden.mismatchedTokenAndUserId"}]}
    end
  end

  def handle_index_query(%{query_params: qp} = conn, query) do
    current_user_id = String.to_integer(Api.Accounts.Guardian.Plug.current_claims(conn)["sub"] || "-1")
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
