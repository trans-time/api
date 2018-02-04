defmodule Api.RelationshipTest do
  use Api.DataCase

  alias Api.Relationship

  describe "follows" do
    alias Api.Relationship.Follow

    @valid_attrs %{can_view_private: true, requested_private: true}
    @update_attrs %{can_view_private: false, requested_private: false}
    @invalid_attrs %{can_view_private: nil, requested_private: nil}

    def follow_fixture(attrs \\ %{}) do
      {:ok, follow} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Relationship.create_follow()

      follow
    end

    test "list_follows/0 returns all follows" do
      follow = follow_fixture()
      assert Relationship.list_follows() == [follow]
    end

    test "get_follow!/1 returns the follow with given id" do
      follow = follow_fixture()
      assert Relationship.get_follow!(follow.id) == follow
    end

    test "create_follow/1 with valid data creates a follow" do
      assert {:ok, %Follow{} = follow} = Relationship.create_follow(@valid_attrs)
      assert follow.can_view_private == true
      assert follow.requested_private == true
    end

    test "create_follow/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Relationship.create_follow(@invalid_attrs)
    end

    test "update_follow/2 with valid data updates the follow" do
      follow = follow_fixture()
      assert {:ok, follow} = Relationship.update_follow(follow, @update_attrs)
      assert %Follow{} = follow
      assert follow.can_view_private == false
      assert follow.requested_private == false
    end

    test "update_follow/2 with invalid data returns error changeset" do
      follow = follow_fixture()
      assert {:error, %Ecto.Changeset{}} = Relationship.update_follow(follow, @invalid_attrs)
      assert follow == Relationship.get_follow!(follow.id)
    end

    test "delete_follow/1 deletes the follow" do
      follow = follow_fixture()
      assert {:ok, %Follow{}} = Relationship.delete_follow(follow)
      assert_raise Ecto.NoResultsError, fn -> Relationship.get_follow!(follow.id) end
    end

    test "change_follow/1 returns a follow changeset" do
      follow = follow_fixture()
      assert %Ecto.Changeset{} = Relationship.change_follow(follow)
    end
  end
end
