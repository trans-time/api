import Ecto.Query

defmodule ApiWeb.TagController do
  use ApiWeb, :controller
  use JaResource # Optionally put in web/web.ex
  plug JaResource

  alias Api.Timeline.Tag

  def model, do: Tag

  def filter(_conn, query, "like_name", name) do
    safe_query = "%#{String.replace(name, "%", "\\%")}%"
    query
    |> where([t], ilike(t.name, ^safe_query))
    |> order_by(desc: :tagging_count)
  end

  def filter(_conn, query, "limit", limit) do
    query
    |> limit(^limit)
  end
end
