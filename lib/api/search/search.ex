defmodule Api.Search do
  @moduledoc """
  The Search context.
  """

  import Ecto.Query, warn: false
  alias Api.Repo

  alias Api.Search.SearchQuery

  @doc """
  Returns the list of search_queries.

  ## Examples

      iex> list_search_queries()
      [%SearchQuery{}, ...]

  """
  def list_search_queries do
    Repo.all(SearchQuery)
  end

  @doc """
  Gets a single search_query.

  Raises `Ecto.NoResultsError` if the Search query does not exist.

  ## Examples

      iex> get_search_query!(123)
      %SearchQuery{}

      iex> get_search_query!(456)
      ** (Ecto.NoResultsError)

  """
  def get_search_query!(id), do: Repo.get!(SearchQuery, id)

  @doc """
  Creates a search_query.

  ## Examples

      iex> create_search_query(%{field: value})
      {:ok, %SearchQuery{}}

      iex> create_search_query(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_search_query(attrs \\ %{}) do
    %SearchQuery{}
    |> SearchQuery.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a search_query.

  ## Examples

      iex> update_search_query(search_query, %{field: new_value})
      {:ok, %SearchQuery{}}

      iex> update_search_query(search_query, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_search_query(%SearchQuery{} = search_query, attrs) do
    search_query
    |> SearchQuery.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a SearchQuery.

  ## Examples

      iex> delete_search_query(search_query)
      {:ok, %SearchQuery{}}

      iex> delete_search_query(search_query)
      {:error, %Ecto.Changeset{}}

  """
  def delete_search_query(%SearchQuery{} = search_query) do
    Repo.delete(search_query)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking search_query changes.

  ## Examples

      iex> change_search_query(search_query)
      %Ecto.Changeset{source: %SearchQuery{}}

  """
  def change_search_query(%SearchQuery{} = search_query) do
    SearchQuery.changeset(search_query, %{})
  end
end
