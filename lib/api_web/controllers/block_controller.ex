defmodule ApiWeb.BlockController do
  use ApiWeb, :controller
  use JaResource # Optionally put in web/web.ex
  plug JaResource

  alias Api.Relationship.Block

  def model, do: Block

  def handle_create(conn, attributes) do
    current_user_id = Api.Accounts.Guardian.Plug.current_claims(conn)["sub"]

    case attributes["blocker_id"] do
      ^current_user_id -> Block.changeset(%Block{}, attributes)
      _ -> {:error, [%{status: "403", source: %{pointer: "/data/relationships/blocker/data/id"}, title: "remote.errors.title.forbidden", detail: "remote.errors.detail.forbidden.mismatchedTokenAndUserId"}]}
    end
  end

  def handle_delete(conn, record) do
    current_user_id = String.to_integer(Api.Accounts.Guardian.Plug.current_claims(conn)["sub"])

    case record.blocker_id do
      ^current_user_id -> super(conn, record)
      _ -> {:error, [%{status: "403", source: %{pointer: "/data/relationships/blocker/data/id"}, title: "remote.errors.title.forbidden", detail: "remote.errors.detail.forbidden.mismatchedTokenAndUserId"}]}
    end
  end
end
