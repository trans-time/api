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

  describe "posts" do
    alias Api.Timeline.Post

    @valid_attrs %{nsfw: true, text: "some text"}
    @update_attrs %{nsfw: false, text: "some updated text"}
    @invalid_attrs %{nsfw: nil, text: nil}

    def post_fixture(attrs \\ %{}) do
      {:ok, post} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Timeline.create_post()

      post
    end

    test "list_posts/0 returns all posts" do
      post = post_fixture()
      assert Timeline.list_posts() == [post]
    end

    test "get_post!/1 returns the post with given id" do
      post = post_fixture()
      assert Timeline.get_post!(post.id) == post
    end

    test "create_post/1 with valid data creates a post" do
      assert {:ok, %Post{} = post} = Timeline.create_post(@valid_attrs)
      assert post.nsfw == true
      assert post.text == "some text"
    end

    test "create_post/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Timeline.create_post(@invalid_attrs)
    end

    test "update_post/2 with valid data updates the post" do
      post = post_fixture()
      assert {:ok, post} = Timeline.update_post(post, @update_attrs)
      assert %Post{} = post
      assert post.nsfw == false
      assert post.text == "some updated text"
    end

    test "update_post/2 with invalid data returns error changeset" do
      post = post_fixture()
      assert {:error, %Ecto.Changeset{}} = Timeline.update_post(post, @invalid_attrs)
      assert post == Timeline.get_post!(post.id)
    end

    test "delete_post/1 deletes the post" do
      post = post_fixture()
      assert {:ok, %Post{}} = Timeline.delete_post(post)
      assert_raise Ecto.NoResultsError, fn -> Timeline.get_post!(post.id) end
    end

    test "change_post/1 returns a post changeset" do
      post = post_fixture()
      assert %Ecto.Changeset{} = Timeline.change_post(post)
    end
  end

  describe "panels" do
    alias Api.Timeline.Panel

    @valid_attrs %{filename: "some filename", filesize: 42, order: 42, src: "some src"}
    @update_attrs %{filename: "some updated filename", filesize: 43, order: 43, src: "some updated src"}
    @invalid_attrs %{filename: nil, filesize: nil, order: nil, src: nil}

    def panel_fixture(attrs \\ %{}) do
      {:ok, panel} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Timeline.create_panel()

      panel
    end

    test "list_panels/0 returns all panels" do
      panel = panel_fixture()
      assert Timeline.list_panels() == [panel]
    end

    test "get_panel!/1 returns the panel with given id" do
      panel = panel_fixture()
      assert Timeline.get_panel!(panel.id) == panel
    end

    test "create_panel/1 with valid data creates a panel" do
      assert {:ok, %Panel{} = panel} = Timeline.create_panel(@valid_attrs)
      assert panel.filename == "some filename"
      assert panel.filesize == 42
      assert panel.order == 42
      assert panel.src == "some src"
    end

    test "create_panel/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Timeline.create_panel(@invalid_attrs)
    end

    test "update_panel/2 with valid data updates the panel" do
      panel = panel_fixture()
      assert {:ok, panel} = Timeline.update_panel(panel, @update_attrs)
      assert %Panel{} = panel
      assert panel.filename == "some updated filename"
      assert panel.filesize == 43
      assert panel.order == 43
      assert panel.src == "some updated src"
    end

    test "update_panel/2 with invalid data returns error changeset" do
      panel = panel_fixture()
      assert {:error, %Ecto.Changeset{}} = Timeline.update_panel(panel, @invalid_attrs)
      assert panel == Timeline.get_panel!(panel.id)
    end

    test "delete_panel/1 deletes the panel" do
      panel = panel_fixture()
      assert {:ok, %Panel{}} = Timeline.delete_panel(panel)
      assert_raise Ecto.NoResultsError, fn -> Timeline.get_panel!(panel.id) end
    end

    test "change_panel/1 returns a panel changeset" do
      panel = panel_fixture()
      assert %Ecto.Changeset{} = Timeline.change_panel(panel)
    end
  end

  describe "reactions" do
    alias Api.Timeline.Reaction

    @valid_attrs %{type: 42}
    @update_attrs %{type: 43}
    @invalid_attrs %{type: nil}

    def reaction_fixture(attrs \\ %{}) do
      {:ok, reaction} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Timeline.create_reaction()

      reaction
    end

    test "list_reactions/0 returns all reactions" do
      reaction = reaction_fixture()
      assert Timeline.list_reactions() == [reaction]
    end

    test "get_reaction!/1 returns the reaction with given id" do
      reaction = reaction_fixture()
      assert Timeline.get_reaction!(reaction.id) == reaction
    end

    test "create_reaction/1 with valid data creates a reaction" do
      assert {:ok, %Reaction{} = reaction} = Timeline.create_reaction(@valid_attrs)
      assert reaction.type == 42
    end

    test "create_reaction/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Timeline.create_reaction(@invalid_attrs)
    end

    test "update_reaction/2 with valid data updates the reaction" do
      reaction = reaction_fixture()
      assert {:ok, reaction} = Timeline.update_reaction(reaction, @update_attrs)
      assert %Reaction{} = reaction
      assert reaction.type == 43
    end

    test "update_reaction/2 with invalid data returns error changeset" do
      reaction = reaction_fixture()
      assert {:error, %Ecto.Changeset{}} = Timeline.update_reaction(reaction, @invalid_attrs)
      assert reaction == Timeline.get_reaction!(reaction.id)
    end

    test "delete_reaction/1 deletes the reaction" do
      reaction = reaction_fixture()
      assert {:ok, %Reaction{}} = Timeline.delete_reaction(reaction)
      assert_raise Ecto.NoResultsError, fn -> Timeline.get_reaction!(reaction.id) end
    end

    test "change_reaction/1 returns a reaction changeset" do
      reaction = reaction_fixture()
      assert %Ecto.Changeset{} = Timeline.change_reaction(reaction)
    end
  end
end
