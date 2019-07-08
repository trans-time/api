import Ecto.Query

defmodule ApiWeb.UserController do
  use ApiWeb, :controller
  use JaResource # Optionally put in web/web.ex
  plug JaResource

  alias Api.Accounts.Guardian
  alias Api.Accounts.User
  alias Api.Profile.UserIdentity
  alias ApiWeb.Services.UserManager
  alias Ecto.Multi

  def model, do: User

  def handle_create(conn, attributes) do
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
  end

  def handle_index_query(conn, query) do
    current_user_id = String.to_integer(Api.Accounts.Guardian.Plug.current_claims(conn)["sub"] || "-1")
    query = if current_user_id == -1, do: hide_private_accounts(conn, query), else: query

    repo().all(query)
  end

  def handle_update(conn, user, attributes) do
    current_user_id =  String.to_integer(Api.Accounts.Guardian.Plug.current_claims(conn)["sub"] || "-1")
    case user.id do
      ^current_user_id -> Api.Repo.update(User.public_update_changeset(user, attributes))
      _                -> {:error, [%{status: "403", source: %{pointer: "/data/relationships/user/data/id"}, title: "remote.errors.title.forbidden", detail: "remote.errors.detail.forbidden.mismatchedTokenAndUserId"}]}
    end
  end

  def hide_private_accounts(_conn, query) do
    query
    |> where([u], u.is_public == ^true)
  end

  def sort(_conn, query, "post_count", direction) do
    query
    |> join(:inner, [u], p in assoc(u, :user_profile), u.id == p.user_id)
    |> order_by([u, ..., p], [{^direction, p.post_count}])
    |> group_by([u, ..., p], [u.id, p.post_count])
  end

  def sort(conn, query, "shared_identities", direction) do
    current_user_id =  String.to_integer(Api.Accounts.Guardian.Plug.current_claims(conn)["sub"] || "-1")
    user_identities = Api.Repo.all(from ui in UserIdentity, where: ui.user_id == ^current_user_id)
    identity_ids = Enum.map(user_identities, fn (ui) -> ui.identity_id end)

    shared_identity_subquery =
      User
      |> join(:inner, [u], ui in assoc(u, :user_identities), ui.identity_id in ^identity_ids)
      |> Api.Repo.aggregate(:count, :id)

    query
    |> join(:left, [u], ui in assoc(u, :user_identities), ui.identity_id in ^identity_ids)
    |> order_by([u, ..., ui], [{^direction, count(ui.id)}])
    |> group_by([u], [u.id])
  end

  def filter(conn, query, "no_prior_relation", no_prior_relation) do
    current_user_id =  String.to_integer(Api.Accounts.Guardian.Plug.current_claims(conn)["sub"] || "-1")
    query
    |> join(:left, [u], f in assoc(u, :followers), f.follower_id == ^current_user_id)
    |> join(:left, [u], bd in assoc(u, :blockeds), bd.blocker_id != ^current_user_id)
    |> join(:left, [u], br in assoc(u, :blockers), br.blocked_id != ^current_user_id)
    |> where([u, ..., f, bd, br], u.id != ^current_user_id and is_nil(f.follower_id) and is_nil(bd.blocker_id) and is_nil(br.blocked_id))
    |> group_by([u], [u.id])
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
