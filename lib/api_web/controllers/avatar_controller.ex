defmodule ApiWeb.AvatarController do
  use ApiWeb, :controller
  alias Api.Accounts.User

  def create(conn, params) do
    current_user_id = String.to_integer(Api.Accounts.Guardian.Plug.current_claims(conn)["sub"] || "-1")
    IO.inspect(params["file"])
    changeset = User.changeset(Api.Repo.get(User, current_user_id), %{"avatar" => params["file"]})
    case Api.Repo.update(changeset) do
      {:ok, user} ->
        conn
        |> put_status(201)
        |> put_view(ApiWeb.UserView)
        |> render("show.json-api", data: user)
      {:error, changeset} ->
        conn
        |> put_status(422)
        |> put_view(ApiWeb.UserView)
        |> render("errors.json-api", data: changeset)
    end
  end
end
