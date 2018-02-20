defmodule ApiWeb.UserController do
  use ApiWeb, :controller
  use JaResource # Optionally put in web/web.ex
  plug JaResource

  def model, do: Api.Accounts.User

  def record(conn, username) do
    conn
    |> records
    |> Api.Repo.get_by(username: username)
  end
end
