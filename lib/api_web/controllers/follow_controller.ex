import Ecto.Query, only: [where: 2]

defmodule ApiWeb.FollowController do
  use ApiWeb, :controller
  use JaResource # Optionally put in web/web.ex
  plug JaResource

  def model, do: Api.Relationship.Follow

  def filter(_conn, query, "followed_id", followed_id) do
    where(query, followed_id: ^followed_id)
  end

  def filter(_conn, query, "follower_id", follower_id) do
    where(query, follower_id: ^follower_id)
  end

  def handle_index_query(%{query_params: qp}, query) do
    repo().paginate(query, qp)
  end

  def serialization_opts(_conn, params, models) do
    %{
      include: params["include"],
      meta: %{
        total_pages: models.total_pages
      }
    }
  end
end
