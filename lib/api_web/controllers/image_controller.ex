import Ecto.Query

defmodule ApiWeb.ImageController do
  use ApiWeb, :controller
  use JaResource # Optionally put in web/web.ex
  plug JaResource
  alias Api.Timeline.{Post, TimelineItem}
  alias ApiWeb.Services.ImageManager

  def model, do: Api.Timeline.Image

  def handle_create(conn, attributes) do
    post = Api.Repo.one!(Post |> where(id: ^attributes["post_id"]) |> preload(:timeline_item))
    handle_request(conn, post.timeline_item.user_id, ImageManager.insert(attributes))
  end

  def handle_delete(conn, record) do
    post = Api.Repo.one!(Post |> where(id: ^record.post_id) |> preload(:timeline_item))
    handle_request(conn, post.timeline_item.user_id, ImageManager.delete(record, %{is_marked_for_deletion_by_user: true}))
  end

  def handle_update(conn, record, attributes) do
    post = Api.Repo.one!(Post |> where(id: ^record.post_id) |> preload(:timeline_item))
    handle_request(conn, post.timeline_item.user_id, ImageManager.update(record, attributes))
  end

  defp handle_request(conn, user_id, multi) do
    current_user_id = String.to_integer(Api.Accounts.Guardian.Plug.current_claims(conn)["sub"] || "-1")

    case user_id do
      ^current_user_id ->
        transaction = Api.Repo.transaction(multi)
        if Kernel.elem(transaction, 0) === :ok, do: Kernel.elem(transaction, 1).image, else: transaction
      _ -> {:error, [%{status: "403", source: %{pointer: "/data/relationships/user/data/id"}, title: "remote.errors.title.forbidden", detail: "remote.errors.detail.forbidden.mismatchedTokenAndUserId"}]}
    end
  end
end
