import Ecto.Query

defmodule ApiWeb.CommentController do
  use ApiWeb, :controller
  use JaResource # Optionally put in web/web.ex
  plug JaResource

  alias Api.Timeline.Comment

  def model, do: Comment

  def filter(_conn, query, "post_id", post_id) do
    where(query, post_id: ^post_id)
  end
end
