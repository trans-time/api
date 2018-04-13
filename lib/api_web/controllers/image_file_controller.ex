import Ecto.Query

defmodule ApiWeb.ImageFileController do
  use ApiWeb, :controller
  alias Api.Timeline.{Image, ImageFile}

  def create(conn, params) do
    image = Api.Repo.one!(Api.Timeline.Image
      |> where(id: ^params["image_id"])
      |> join(:left, [i], p in assoc(i, :post))
      |> join(:left, [i, p], ti in assoc(p, :timeline_item))
      |> preload([i, p, ti], [post: {p, timeline_item: ti}])
    )
    handle_request(conn, image.post.timeline_item.user_id, fn  ->
      IO.inspect(params["file"])
      changeset = Image.changeset(image, %{"src" => params["file"]})

      case Api.Repo.update(changeset) do
        {:ok, image} ->
          conn
          |> put_status(201)
          |> put_view(ApiWeb.ImageView)
          |> render("show.json-api", data: image)
        {:error, changeset} ->
          conn
          |> put_status(422)
          |> put_view(ApiWeb.ImageView)
          |> render("errors.json-api", data: changeset)
      end
    end)
  end

  def delete(conn, params) do
    image = Api.Repo.one!(Api.Timeline.Image
      |> where(id: ^params["image_id"])
      |> join(:left, [i], p in assoc(i, :post))
      |> join(:left, [i, p], ti in assoc(p, :timeline_item))
      |> preload([i, p, ti], [post: p, timeline_item: ti])
    )
    handle_request(conn, image.user_id, fn ->
      changeset = Image.changeset(image, %{"src" => nil})

      case Api.Repo.update(changeset) do
        {:ok, image} ->
          Enum.each(ImageFile.get_versions(), fn (version) ->
            Image.delete({Image.url({image.src, image}, version), image})
          end)
          conn
          |> put_status(204)
          |> put_view(ApiWeb.ImageView)
          |> render("show.json-api", data: image)
        {:error, changeset} ->
          conn
          |> put_status(422)
          |> put_view(ApiWeb.ImageView)
          |> render("errors.json-api", data: changeset)
      end
    end)
  end

  defp handle_request(conn, user_id, cb) do
    current_user_id = String.to_integer(Api.Accounts.Guardian.Plug.current_claims(conn)["sub"] || "-1")

    case user_id do
      ^current_user_id -> cb.()
      _ ->
        conn
        |> put_status(422)
        |> put_view(ApiWeb.ImageView)
        |> render("errors.json-api", data: [%{status: "403", source: %{pointer: "/data/relationships/user/data/id"}, title: "remote.errors.title.forbidden", detail: "remote.errors.detail.forbidden.mismatchedTokenAndUserId"}])
    end
  end
end
