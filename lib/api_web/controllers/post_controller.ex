defmodule ApiWeb.PostController do
  use ApiWeb, :controller
  use JaResource # Optionally put in web/web.ex
  plug JaResource

  def model, do: Api.Timeline.Post

  # def record(conn, username) do
  #   conn
  #   |> records
  #   |> Api.Repo.get_by(username: username)
  # end
end
