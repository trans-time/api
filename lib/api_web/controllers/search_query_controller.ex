import Ecto.Query

defmodule ApiWeb.SearchQueryController do
  use ApiWeb, :controller
  use JaResource # Optionally put in web/web.ex
  plug JaResource

  def model, do: Api.Search.SearchQuery

  def handle_index_query(%{query_params: qp}, _query) do
    full_query = qp["filter"]["query"]
    query_type = case String.at(full_query, 0) do
      "@" -> :user
      "#" -> :tag
      "*" -> :identity
      _ -> :generic
    end

    main_query = if (query_type == :generic), do: full_query, else: String.slice(full_query, 1..-1)
    safe_query = "%#{String.replace(main_query, "%", "\\%")}%"
    identities = if (query_type == :generic || query_type == :identity), do: identities_query(safe_query), else: []
    tags = if (query_type == :generic || query_type == :tag), do: tags_query(safe_query), else: []
    users = if (query_type == :generic || query_type == :user), do: users_query(safe_query), else: []

    %Api.Search.SearchQuery{
      identities: identities,
      tags: tags,
      users: users,
      query: full_query
    }
  end

  def identities_query(query) do
    Api.Repo.all(from i in Api.Profile.Identity,
      where: ilike(i.name, ^query),
      order_by: [desc: :user_identity_count],
      limit: 5)
  end

  def tags_query(query) do
    Api.Repo.all(from t in Api.Timeline.Tag,
      where: ilike(t.name, ^query),
      order_by: [desc: :tagging_count],
      limit: 5)
  end

  def users_query(query) do
    Api.Repo.all(from u in Api.Accounts.User,
      where: ilike(u.username, ^query) or ilike(u.display_name, ^query),
      order_by: [desc: :follower_count],
      limit: 5)
  end
end
