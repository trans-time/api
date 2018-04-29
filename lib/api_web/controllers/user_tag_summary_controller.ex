import Ecto.Query

defmodule ApiWeb.UserTagSummaryController do
  use ApiWeb, :controller
  use JaResource # Optionally put in web/web.ex
  plug JaResource

  alias Api.Profile.UserTagSummary

  def model, do: UserTagSummary

  def filter(_conn, query, "author_usernames", author_usernames) do
    join(query, :inner, [], u in "users", u.username in ^author_usernames)
    |> group_by([uts], uts.id)
    |> having([uts, ..., u], uts.author_id in fragment("array_agg(?)", u.id))
  end

  def filter(_conn, query, "author_username", author_username) do
    join(query, :inner, [], u in "users", u.username == ^author_username)
    |> group_by([uts], uts.id)
    |> having([uts, ..., u], uts.author_id in fragment("array_agg(?)", u.id))
  end

  def filter(_conn, query, "subject_id", subject_id) do
    where(query, subject_id: ^subject_id)
  end
end
