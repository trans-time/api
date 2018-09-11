import Ecto.Query

defmodule ApiWeb.UserController do
  use ApiWeb, :controller
  use JaResource # Optionally put in web/web.ex
  plug JaResource

  alias Api.Accounts.Guardian
  alias Api.Accounts.User
  alias ApiWeb.Services.UserManager
  alias Ecto.Multi

  def model, do: User

  def handle_create(conn, attributes) do
    case Recaptcha.verify(attributes["re_captcha_response"]) do
      {:ok, response} ->
        case Api.Accounts.Guardian.Plug.current_claims(conn)["sub"] do
          nil ->
            transaction = Api.Repo.transaction(UserManager.insert_user(attributes))
            if (Kernel.elem(transaction, 0) === :ok) do
              user = Kernel.elem(transaction, 1).user
              auth_conn = Guardian.Plug.sign_in(conn, user)
              jwt = Guardian.Plug.current_token(auth_conn)
              Map.put(user, :token, jwt)
            else
              transaction
            end
          _ -> {:error, [%{status: "403", source: %{pointer: "/data/relationships/user/data/id"}, title: "remote.errors.title.forbidden", detail: "remote.errors.detail.forbidden.mismatchedTokenAndUserId"}]}
        end
      {:error, errors} -> invalid_recaptcha(conn)
    end
  end

  defp invalid_recaptcha(conn) do
    conn
    |> put_status(401)
    |> json(%{errors: [%{title: "remote.errors.title.invalid", detail: "remote.errors.detail.invalid.recaptcha", status: "401"}]})
  end

  def filter(_conn, query, "username", username) do
    where(query, username: ^username)
  end

  def filter(_conn, query, "like_username", username) do
    safe_query = "%#{String.replace(username, "%", "\\%")}%"
    query
    |> where([u], ilike(u.username, ^safe_query) or ilike(u.display_name, ^safe_query))
    |> order_by(desc: :follower_count)
  end

  def filter(_conn, query, "limit", limit) do
    query
    |> limit(^limit)
  end
end
