import Ecto.Query

defmodule ApiWeb.PostController do
  use ApiWeb, :controller
  use JaResource # Optionally put in web/web.ex
  plug JaResource
  alias Api.Timeline.{Post, TimelineItem}
  alias ApiWeb.Services.PostManager

  def model, do: Api.Timeline.Post

  def handle_create(conn, attributes) do
    handle_request(conn, String.to_integer(attributes["user_id"]), PostManager.insert(attributes, Api.Accounts.Guardian.Plug.current_resource(conn)))
  end

  def handle_delete(conn, record) do
    timeline_item = Api.Repo.get!(TimelineItem, record.timeline_item_id)
    handle_request(conn, timeline_item.user_id, PostManager.delete(record, timeline_item, %{is_marked_for_deletion_by_user: true}))
  end

  def handle_update(conn, record, attributes) do
    handle_request(conn, Api.Repo.get!(TimelineItem, record.timeline_item_id).user_id, PostManager.update(record, attributes, Api.Accounts.Guardian.Plug.current_resource(conn)))
  end

  defp handle_request(conn, user_id, multi) do
    current_user_id = String.to_integer(Api.Accounts.Guardian.Plug.current_claims(conn)["sub"] || "-1")

    case user_id do
      ^current_user_id ->
        transaction = Api.Repo.transaction(multi)
        if Kernel.elem(transaction, 0) === :ok, do: Kernel.elem(transaction, 1).timelineable, else: transaction
      _ -> {:error, [%{status: "403", source: %{pointer: "/data/relationships/user/data/id"}, title: "remote.errors.title.forbidden", detail: "remote.errors.detail.forbidden.mismatchedTokenAndUserId"}]}
    end
  end

  def handle_show(conn, id) do
    current_user_id = String.to_integer(Api.Accounts.Guardian.Plug.current_claims(conn)["sub"] || "-1")

    if (current_user_id == -1) do
      query = Post
      |> where([p], p.id == ^id)
      |> join(:inner, [p], ti in assoc(p, :timeline_item), p.timeline_item_id == ti.id)
      |> join(:inner, [p, ti], u in assoc(ti, :user), u.is_public == ^true)
      |> group_by([p], [p.id])
      repo().one(query)
    else
      repo().get(Post, id)
    end
  end
end
