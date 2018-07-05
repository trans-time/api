defmodule ApiWeb.HealthController do
  use ApiWeb, :controller

  def index(conn, _params) do
    Plug.Conn.send_resp(conn, 200, "healthy")
  end
end
