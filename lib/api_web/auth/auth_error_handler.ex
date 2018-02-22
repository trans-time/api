defmodule ApiWeb.Guardian.AuthErrorHandler do
  use ApiWeb, :controller

  def auth_error(conn, {type, _reason}, _opts) do
    conn
    |> put_status(401)
    |> render(ApiWeb.ErrorView, "401.json-api")
  end
end
