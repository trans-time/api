defmodule ApiWeb.AuthController do
  use ApiWeb, :controller
  plug Ueberauth

  alias Api.Accounts.Guardian
  alias Api.Accounts.User

  def delete(conn, _params) do
    # Sign out the user
    conn
    |> put_status(200)
    |> Guardian.Plug.sign_out(conn)
  end

  def identity_callback(conn, %{"data" => %{ "attributes" => attributes }}) do
    user = User.get_user_by_identification(Map.get(attributes, "identification"))
    if User.validate_password(user, Map.get(attributes, "password")) do
      { :ok, jwt, _ } = Guardian.encode_and_sign(user)
      auth_conn = Guardian.Plug.sign_in(conn, user)
      jwt = Guardian.Plug.current_token(auth_conn)
      auth_conn
      |> put_resp_header("authorization", "Bearer #{jwt}")
      |> json(%{token: jwt, username: user.username}) # Return token to the client
    else
      # Unsuccessful login
      conn
      |> put_status(401)
      |> render(ApiWeb.ErrorView, "401.json-api")
    end
  end
end
