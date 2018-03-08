import Ecto.Query

defmodule ApiWeb.UserIdentityController do
  use ApiWeb, :controller
  use JaResource # Optionally put in web/web.ex
  plug JaResource

  alias Api.Profile.UserIdentity
  alias ApiWeb.Services.UserIdentityManager

  def model, do: UserIdentity

  def handle_create(conn, attributes) do
    handle_request(conn, String.to_integer(attributes["user_id"]), UserIdentityManager.insert(attributes))
  end

  def handle_delete(conn, record) do
    handle_request(conn, record.user_id, UserIdentityManager.delete(record))
  end

  def handle_update(conn, record, attributes) do
    handle_request(conn, record.user_id, UserIdentityManager.update(record, attributes))
  end

  defp handle_request(conn, user_id, multi) do
    current_user_id = String.to_integer(Api.Accounts.Guardian.Plug.current_claims(conn)["sub"] || "-1")

    case user_id do
      ^current_user_id ->
        transaction = Api.Repo.transaction(multi)
        if Kernel.elem(transaction, 0) === :ok, do: Kernel.elem(transaction, 1).user_identity, else: transaction
      _ -> {:error, [%{status: "403", source: %{pointer: "/data/relationships/user/data/id"}, title: "remote.errors.title.forbidden", detail: "remote.errors.detail.forbidden.mismatchedTokenAndUserId"}]}
    end
  end
end
