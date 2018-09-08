import Ecto.Query

defmodule ApiWeb.SubscriptionTypeController do
  use ApiWeb, :controller
  alias Api.Accounts.User
  alias Api.Mail.{MailSubscriptionToken, Subscription, SubscriptionType}

  def index(conn, params) do
    current_user_id = get_current_user_id(conn)
    subscription_types = Api.Repo.preload(Api.Repo.all(SubscriptionType), [subscriptions: from(s in Subscription, where: s.user_id == ^current_user_id)])

    conn
    |> put_status(200)
    |> put_view(ApiWeb.SubscriptionTypeView)
    |> render("show.json-api", data: subscription_types)
  end

  defp handle_request(conn, user_id, cb) do
    current_user_id = String.to_integer(Api.Accounts.Guardian.Plug.current_claims(conn)["sub"] || "-1")
    current_user_id = if (current_user_id == -1), do: Api.Repo.get_by(User, mail_token: conn.params["mail_token"]), else: current_user_id

    case user_id do
      ^current_user_id -> cb.()
      _ ->
        conn
        |> put_status(422)
        |> put_view(ApiWeb.ImageView)
        |> render("errors.json-api", data: [%{status: "403", source: %{pointer: "/data/relationships/user/data/id"}, title: "remote.errors.title.forbidden", detail: "remote.errors.detail.forbidden.mismatchedTokenAndUserId"}])
    end
  end

  defp get_current_user_id(conn) do
    current_user_id = String.to_integer(Api.Accounts.Guardian.Plug.current_claims(conn)["sub"] || "-1")

    if (current_user_id == -1 && conn.params["mail_subscription_token"] != "") do
      Api.Repo.get_by(MailSubscriptionToken, token: conn.params["mail_subscription_token"]).user_id
    else
      current_user_id
    end
  end
end
