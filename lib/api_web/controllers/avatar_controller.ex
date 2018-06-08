defmodule ApiWeb.AvatarController do
  use ApiWeb, :controller
  alias Api.Accounts.User
  alias Api.Profile.Avatar

  def create(conn, params) do
    current_user_id = String.to_integer(Api.Accounts.Guardian.Plug.current_claims(conn)["sub"] || "-1")
    changeset = User.public_update_changeset(Api.Repo.get(User, current_user_id), %{"avatar" => params["file"]})

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

  def delete(conn, params) do
    current_user_id = String.to_integer(Api.Accounts.Guardian.Plug.current_claims(conn)["sub"] || "-1")
    current_user = Api.Repo.get(User, current_user_id)
    changeset = User.public_update_changeset(current_user, %{"avatar" => nil})

    case Api.Repo.update(changeset) do
      {:ok, user} ->
        Enum.each(Avatar.get_versions(), fn (version) ->
          Avatar.delete({Avatar.url({current_user.avatar, current_user}, version), current_user})
        end)
        conn
        |> put_status(204)
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
