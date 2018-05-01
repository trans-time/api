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
    timeline_item = Api.Repo.get_by!(TimelineItem, post_id: record.id)
    handle_request(conn, timeline_item.user_id, PostManager.delete(record, timeline_item, %{deleted_by_user: true}))
  end

  def handle_update(conn, record, attributes) do
    handle_request(conn, Api.Repo.get_by!(TimelineItem, post_id: record.id).user_id, PostManager.update(record, attributes, Api.Accounts.Guardian.Plug.current_resource(conn)))
  end

  defp handle_request(conn, user_id, multi) do
    current_user_id = String.to_integer(Api.Accounts.Guardian.Plug.current_claims(conn)["sub"] || "-1")

    case user_id do
      ^current_user_id ->
        transaction = Api.Repo.transaction(multi)
        if Kernel.elem(transaction, 0) === :ok, do: Kernel.elem(transaction, 1).post, else: transaction
      _ -> {:error, [%{status: "403", source: %{pointer: "/data/relationships/user/data/id"}, title: "remote.errors.title.forbidden", detail: "remote.errors.detail.forbidden.mismatchedTokenAndUserId"}]}
    end
  end
end
