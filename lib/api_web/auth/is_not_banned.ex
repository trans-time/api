defmodule ApiWeb.Plugs.IsNotBanned do
  import Plug.Conn

  def init(default), do: default

  def call(conn, _default) do
    current_user = Api.Repo.get(Api.Accounts.User, String.to_integer(Api.Accounts.Guardian.Plug.current_claims(conn)["sub"] || "-1"))

    if (!current_user || !current_user.is_banned) do
      conn
    else
      conn
        |> put_status(403)
        |> Phoenix.Controller.put_view(ApiWeb.ImageView)
        |> Phoenix.Controller.render("errors.json-api", data: [%{status: "403", source: %{pointer: "/data/relationships/user/data/isBanned"}, title: "remote.errors.title.forbidden", detail: "remote.errors.detail.forbidden.mustNotBeBanned"}])
        |> halt()
    end
  end
end
