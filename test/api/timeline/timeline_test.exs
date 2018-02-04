defmodule Api.TimelineTest do
  use Api.DataCase

  alias Api.Timeline

  describe "tags" do
    alias Api.Timeline.Tag

    @valid_attrs %{name: "some name"}
    @update_attrs %{name: "some updated name"}
    @invalid_attrs %{name: nil}

    def tag_fixture(attrs \\ %{}) do
      {:ok, tag} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Timeline.create_tag()

      tag
    end

    test "list_tags/0 returns all tags" do
      tag = tag_fixture()
      assert Timeline.list_tags() == [tag]
    end

    test "get_tag!/1 returns the tag with given id" do
      tag = tag_fixture()
      assert Timeline.get_tag!(tag.id) == tag
    end

    test "create_tag/1 with valid data creates a tag" do
      assert {:ok, %Tag{} = tag} = Timeline.create_tag(@valid_attrs)
      assert tag.name == "some name"
    end

    test "create_tag/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Timeline.create_tag(@invalid_attrs)
    end

    test "update_tag/2 with valid data updates the tag" do
      tag = tag_fixture()
      assert {:ok, tag} = Timeline.update_tag(tag, @update_attrs)
      assert %Tag{} = tag
      assert tag.name == "some updated name"
    end

    test "update_tag/2 with invalid data returns error changeset" do
      tag = tag_fixture()
      assert {:error, %Ecto.Changeset{}} = Timeline.update_tag(tag, @invalid_attrs)
      assert tag == Timeline.get_tag!(tag.id)
    end

    test "delete_tag/1 deletes the tag" do
      tag = tag_fixture()
      assert {:ok, %Tag{}} = Timeline.delete_tag(tag)
      assert_raise Ecto.NoResultsError, fn -> Timeline.get_tag!(tag.id) end
    end

    test "change_tag/1 returns a tag changeset" do
      tag = tag_fixture()
      assert %Ecto.Changeset{} = Timeline.change_tag(tag)
    end
  end

  describe "timeline_items" do
    alias Api.Timeline.TimelineItem

    @valid_attrs %{comments_locked: true, date: "2010-04-17 14:00:00.000000Z", deleted: true, private: true, total_comments: 42}
    @update_attrs %{comments_locked: false, date: "2011-05-18 15:01:01.000000Z", deleted: false, private: false, total_comments: 43}
    @invalid_attrs %{comments_locked: nil, date: nil, deleted: nil, private: nil, total_comments: nil}

    def timeline_item_fixture(attrs \\ %{}) do
      {:ok, timeline_item} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Timeline.create_timeline_item()

      timeline_item
    end

    test "list_timeline_items/0 returns all timeline_items" do
      timeline_item = timeline_item_fixture()
      assert Timeline.list_timeline_items() == [timeline_item]
    end

    test "get_timeline_item!/1 returns the timeline_item with given id" do
      timeline_item = timeline_item_fixture()
      assert Timeline.get_timeline_item!(timeline_item.id) == timeline_item
    end

    test "create_timeline_item/1 with valid data creates a timeline_item" do
      assert {:ok, %TimelineItem{} = timeline_item} = Timeline.create_timeline_item(@valid_attrs)
      assert timeline_item.comments_locked == true
      assert timeline_item.date == DateTime.from_naive!(~N[2010-04-17 14:00:00.000000Z], "Etc/UTC")
      assert timeline_item.deleted == true
      assert timeline_item.private == true
      assert timeline_item.total_comments == 42
    end

    test "create_timeline_item/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Timeline.create_timeline_item(@invalid_attrs)
    end

    test "update_timeline_item/2 with valid data updates the timeline_item" do
      timeline_item = timeline_item_fixture()
      assert {:ok, timeline_item} = Timeline.update_timeline_item(timeline_item, @update_attrs)
      assert %TimelineItem{} = timeline_item
      assert timeline_item.comments_locked == false
      assert timeline_item.date == DateTime.from_naive!(~N[2011-05-18 15:01:01.000000Z], "Etc/UTC")
      assert timeline_item.deleted == false
      assert timeline_item.private == false
      assert timeline_item.total_comments == 43
    end

    test "update_timeline_item/2 with invalid data returns error changeset" do
      timeline_item = timeline_item_fixture()
      assert {:error, %Ecto.Changeset{}} = Timeline.update_timeline_item(timeline_item, @invalid_attrs)
      assert timeline_item == Timeline.get_timeline_item!(timeline_item.id)
    end

    test "delete_timeline_item/1 deletes the timeline_item" do
      timeline_item = timeline_item_fixture()
      assert {:ok, %TimelineItem{}} = Timeline.delete_timeline_item(timeline_item)
      assert_raise Ecto.NoResultsError, fn -> Timeline.get_timeline_item!(timeline_item.id) end
    end

    test "change_timeline_item/1 returns a timeline_item changeset" do
      timeline_item = timeline_item_fixture()
      assert %Ecto.Changeset{} = Timeline.change_timeline_item(timeline_item)
    end
  end

  describe "timeline_items_users" do
    alias Api.Timeline.TimelineItemUser

    @valid_attrs %{}
    @update_attrs %{}
    @invalid_attrs %{}

    def timeline_item_user_fixture(attrs \\ %{}) do
      {:ok, timeline_item_user} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Timeline.create_timeline_item_user()

      timeline_item_user
    end

    test "list_timeline_items_users/0 returns all timeline_items_users" do
      timeline_item_user = timeline_item_user_fixture()
      assert Timeline.list_timeline_items_users() == [timeline_item_user]
    end

    test "get_timeline_item_user!/1 returns the timeline_item_user with given id" do
      timeline_item_user = timeline_item_user_fixture()
      assert Timeline.get_timeline_item_user!(timeline_item_user.id) == timeline_item_user
    end

    test "create_timeline_item_user/1 with valid data creates a timeline_item_user" do
      assert {:ok, %TimelineItemUser{} = timeline_item_user} = Timeline.create_timeline_item_user(@valid_attrs)
    end

    test "create_timeline_item_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Timeline.create_timeline_item_user(@invalid_attrs)
    end

    test "update_timeline_item_user/2 with valid data updates the timeline_item_user" do
      timeline_item_user = timeline_item_user_fixture()
      assert {:ok, timeline_item_user} = Timeline.update_timeline_item_user(timeline_item_user, @update_attrs)
      assert %TimelineItemUser{} = timeline_item_user
    end

    test "update_timeline_item_user/2 with invalid data returns error changeset" do
      timeline_item_user = timeline_item_user_fixture()
      assert {:error, %Ecto.Changeset{}} = Timeline.update_timeline_item_user(timeline_item_user, @invalid_attrs)
      assert timeline_item_user == Timeline.get_timeline_item_user!(timeline_item_user.id)
    end

    test "delete_timeline_item_user/1 deletes the timeline_item_user" do
      timeline_item_user = timeline_item_user_fixture()
      assert {:ok, %TimelineItemUser{}} = Timeline.delete_timeline_item_user(timeline_item_user)
      assert_raise Ecto.NoResultsError, fn -> Timeline.get_timeline_item_user!(timeline_item_user.id) end
    end

    test "change_timeline_item_user/1 returns a timeline_item_user changeset" do
      timeline_item_user = timeline_item_user_fixture()
      assert %Ecto.Changeset{} = Timeline.change_timeline_item_user(timeline_item_user)
    end
  end
end
