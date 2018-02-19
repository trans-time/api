import Ecto.Query

defmodule ApiWeb.SearchQueryController do
  use ApiWeb, :controller
  use JaResource # Optionally put in web/web.ex
  plug JaResource

  def model, do: Api.Search.SearchQuery

  def handle_index_query(%{query_params: qp}, _query) do
    query = qp["filter"]["query"]
    safe_query = "%#{String.replace(query, "%", "\\%")}%"
    identities = from t in Api.Profile.Identity,
      where: ilike(t.name, ^safe_query)
    tags = from t in Api.Timeline.Tag,
      where: ilike(t.name, ^safe_query)
    users = from t in Api.Accounts.User,
      where: ilike(t.username, ^safe_query) or ilike(t.display_name, ^safe_query)

    %Api.Search.SearchQuery{
      identities: identities |> Api.Repo.all,
      tags: tags |> Api.Repo.all,
      users: users |> Api.Repo.all
    }
  end
end
