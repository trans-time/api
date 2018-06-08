import Ecto.Query

defmodule ApiWeb.UserPasswordController do
  use ApiWeb, :controller
  use JaResource # Optionally put in web/web.ex
  plug JaResource
  alias Api.Accounts.{User, UserPassword}

  def model, do: User

  def handle_create(conn, attributes) do
    user = Api.Accounts.Guardian.Plug.current_resource(conn)

    if User.validate_password(user, Map.get(attributes, "previous_password")) do
      user_password = Api.Repo.preload(user, :user_password).user_password
      Api.Repo.update(UserPassword.public_update_changeset(user_password, %{password: attributes["new_password"]}))
    else
      invalid_identity(conn)
    end
  end

  defp invalid_identity(conn) do
    conn
    |> put_status(401)
    |> json(%{errors: [%{title: "remote.errors.title.invalid", detail: "remote.errors.detail.invalid.password", status: "401"}]})
  end
end
