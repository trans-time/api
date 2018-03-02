import Ecto.Query, only: [where: 2]

defmodule ApiWeb.UserController do
  use ApiWeb, :controller
  use JaResource # Optionally put in web/web.ex
  plug JaResource

  alias Api.Accounts.User
  alias ApiWeb.Services.UserManager
  alias Ecto.Multi

  def model, do: User

  def handle_create(conn, attributes) do
    case Api.Accounts.Guardian.Plug.current_claims(conn)["sub"] do
      nil ->
        transaction = Api.Repo.transaction(UserManager.insert_user(attributes))
        if Kernel.elem(transaction, 0) === :ok, do: Kernel.elem(transaction, 1).reaction, else: transaction
      _ -> {:error, [%{status: "403", source: %{pointer: "/data/relationships/user/data/id"}, title: "remote.errors.title.forbidden", detail: "remote.errors.detail.forbidden.mismatchedTokenAndUserId"}]}
    end
  end

  def filter(_conn, query, "username", username) do
    where(query, username: ^username)
  end
end
