defmodule ApiWeb.UserController do
  use ApiWeb, :controller
  use JaResource # Optionally put in web/web.ex
  plug JaResource

  alias Api.Accounts.Guardian
  alias Api.Accounts.User

  def model, do: User

  def record(conn, username) do
    conn
    |> records
    |> Api.Repo.get_by(username: username)
  end
end
