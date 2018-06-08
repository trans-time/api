import Ecto.Query

defmodule ApiWeb.EmailChangeController do
  use ApiWeb, :controller
  use JaResource # Optionally put in web/web.ex
  plug JaResource
  alias Api.Accounts.User

  def model, do: User

  def handle_create(conn, attributes) do
    user = Api.Accounts.Guardian.Plug.current_resource(conn)

    if User.validate_password(user, Map.get(attributes, "password")) do
      Api.Repo.update(User.public_update_changeset(user, %{email: attributes["email"]}))
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
