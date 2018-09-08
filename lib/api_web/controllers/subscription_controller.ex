import Ecto.Query

defmodule ApiWeb.SubscriptionController do
  use ApiWeb, :controller
  use JaResource # Optionally put in web/web.ex
  plug JaResource
  alias Api.Accounts.User
  alias Api.Mail.{MailSubscriptionToken, Subscription}

  def model, do: Subscription

  def handle_create(conn, attributes) do
    attributes = Map.put(attributes, "user_id", get_current_user_id(conn))
    changeset = Subscription.changeset(%Subscription{}, attributes)
    Api.Repo.insert(changeset)
  end

  def handle_delete(conn, record) do
    handle_request(conn, record.user_id, fn ->
      Api.Repo.delete(record)
    end)
  end

  defp handle_request(conn, user_id, cb) do
    current_user_id = get_current_user_id(conn)

    case user_id do
      ^current_user_id -> cb.()
      _ -> {:error, [%{status: "403", source: %{pointer: "/data/relationships/user/data/id"}, title: "remote.errors.title.forbidden", detail: "remote.errors.detail.forbidden.mismatchedTokenAndUserId"}]}
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
