defmodule Api.SearchTest do
  use Api.DataCase

  alias Api.Search

  describe "search_queries" do
    alias Api.Search.SearchQuery

    @valid_attrs %{}
    @update_attrs %{}
    @invalid_attrs %{}

    def search_query_fixture(attrs \\ %{}) do
      {:ok, search_query} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Search.create_search_query()

      search_query
    end

    test "list_search_queries/0 returns all search_queries" do
      search_query = search_query_fixture()
      assert Search.list_search_queries() == [search_query]
    end

    test "get_search_query!/1 returns the search_query with given id" do
      search_query = search_query_fixture()
      assert Search.get_search_query!(search_query.id) == search_query
    end

    test "create_search_query/1 with valid data creates a search_query" do
      assert {:ok, %SearchQuery{} = search_query} = Search.create_search_query(@valid_attrs)
    end

    test "create_search_query/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Search.create_search_query(@invalid_attrs)
    end

    test "update_search_query/2 with valid data updates the search_query" do
      search_query = search_query_fixture()
      assert {:ok, search_query} = Search.update_search_query(search_query, @update_attrs)
      assert %SearchQuery{} = search_query
    end

    test "update_search_query/2 with invalid data returns error changeset" do
      search_query = search_query_fixture()
      assert {:error, %Ecto.Changeset{}} = Search.update_search_query(search_query, @invalid_attrs)
      assert search_query == Search.get_search_query!(search_query.id)
    end

    test "delete_search_query/1 deletes the search_query" do
      search_query = search_query_fixture()
      assert {:ok, %SearchQuery{}} = Search.delete_search_query(search_query)
      assert_raise Ecto.NoResultsError, fn -> Search.get_search_query!(search_query.id) end
    end

    test "change_search_query/1 returns a search_query changeset" do
      search_query = search_query_fixture()
      assert %Ecto.Changeset{} = Search.change_search_query(search_query)
    end
  end
end
