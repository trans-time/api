defmodule ApiWeb.Plugs.IsModerator do
  import Plug.Conn

  def init(default), do: default

  def call(conn, _default) do
    current_user = Api.Repo.get(Api.Accounts.User, String.to_integer(Api.Accounts.Guardian.Plug.current_claims(conn)["sub"] || "-1"))

    if (!current_user.is_moderator) do
      conn
        |> put_status(403)
        |> Phoenix.Controller.put_view(ApiWeb.ImageView)
        |> Phoenix.Controller.render("errors.json-api", data: [%{status: "403", source: %{pointer: "/data/relationships/user/data/isModerator"}, title: "remote.errors.title.forbidden", detail: "remote.errors.detail.forbidden.mustBeModerator"}])
        |> halt()
    else
      conn
    end
  end
end

defmodule ApiWeb.Guardian.ModeratorAuthPipeline do
  use Guardian.Plug.Pipeline, otp_app: :api,
                              module: Api.Accounts.Guardian,
                              error_handler: ApiWeb.Guardian.AuthErrorHandler

  plug Guardian.Plug.VerifyHeader, realm: "Bearer"
  plug Guardian.Plug.LoadResource, allow_blank: true
  plug ApiWeb.Plugs.IsNotBanned
  # plug ApiWeb.Plugs.IsModerator
end
