import Ecto.Query, only: [where: 2]

defmodule ApiWeb.UserController do
  use ApiWeb, :controller
  use JaResource # Optionally put in web/web.ex
  plug JaResource

  alias Api.Accounts.Guardian
  alias Api.Accounts.User

  def model, do: User

  def filter(_conn, query, "username", username) do
    where(query, username: ^username)
  end
end
