import Ecto.Query

defmodule ApiWeb.UserTagSummaryController do
  use ApiWeb, :controller
  use JaResource # Optionally put in web/web.ex
  plug JaResource

  alias Api.Profile.UserTagSummary

  def model, do: UserTagSummary

  def filter(_conn, query, "author_id", author_id) do
    where(query, author_id: ^author_id)
  end

  def filter(_conn, query, "subject_id", subject_id) do
    where(query, subject_id: ^subject_id)
  end
end
