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
    case Recaptcha.verify(attributes["re_captcha_response"]) do
      {:ok, response} ->
        case User.get_user_by_identification(Map.get(attributes, "identification")) do
          nil -> invalid_identity(conn)
          user ->
            if User.validate_password(user, Map.get(attributes, "password")) do
              {:ok, _, _} = Guardian.encode_and_sign(user)
              auth_conn = Guardian.Plug.sign_in(conn, user)
              jwt = Guardian.Plug.current_token(auth_conn)
              auth_conn
              |> put_resp_header("authorization", "Bearer #{jwt}")
              |> json(%{token: jwt, username: user.username}) # Return token to the client
            else
              invalid_identity(conn)
            end
        end
      {:error, errors} ->
        conn
        |> put_status(401)
        |> json(%{errors: [%{title: "remote.errors.title.invalid", detail: "remote.errors.detail.invalid.recaptcha", status: "401"}]})
    end
  end

  defp invalid_identity(conn) do
    conn
    |> put_status(401)
    |> json(%{errors: [%{title: "remote.errors.title.invalid", detail: "remote.errors.detail.invalid.usernameOrPassword", status: "401"}]})
  end
end
