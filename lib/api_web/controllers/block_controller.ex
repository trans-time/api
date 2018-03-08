defmodule ApiWeb.BlockController do
  use ApiWeb, :controller
  use JaResource # Optionally put in web/web.ex
  plug JaResource

  alias Api.Relationship.Block

  def model, do: Block

  def handle_create(conn, attributes) do
    handle_request(conn,  String.to_integer(attributes["blocker_id"]), Block.changeset(%Block{}, attributes))
  end

  def handle_delete(conn, record) do
    handle_request(conn, record.blocker_id, super(conn, record))
  end

  defp handle_request(conn, user_id, changeset) do
    current_user_id = String.to_integer(Api.Accounts.Guardian.Plug.current_claims(conn)["sub"] || "-1")

    case user_id do
      ^current_user_id -> changeset
      _ -> {:error, [%{status: "403", source: %{pointer: "/data/relationships/user/data/id"}, title: "remote.errors.title.forbidden", detail: "remote.errors.detail.forbidden.mismatchedTokenAndUserId"}]}
    end
  end
end
