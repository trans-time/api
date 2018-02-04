defmodule ApiWeb.TimelineItemControllerTest do
  use ApiWeb.ConnCase

  alias Api.Timeline
  alias Api.Timeline.TimelineItem

  @create_attrs %{comments_locked: true, date: "2010-04-17 14:00:00.000000Z", deleted: true, private: true, total_comments: 42}
  @update_attrs %{comments_locked: false, date: "2011-05-18 15:01:01.000000Z", deleted: false, private: false, total_comments: 43}
  @invalid_attrs %{comments_locked: nil, date: nil, deleted: nil, private: nil, total_comments: nil}

  def fixture(:timeline_item) do
    {:ok, timeline_item} = Timeline.create_timeline_item(@create_attrs)
    timeline_item
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all timeline_items", %{conn: conn} do
      conn = get conn, timeline_item_path(conn, :index)
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create timeline_item" do
    test "renders timeline_item when data is valid", %{conn: conn} do
      conn = post conn, timeline_item_path(conn, :create), timeline_item: @create_attrs
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get conn, timeline_item_path(conn, :show, id)
      assert json_response(conn, 200)["data"] == %{
        "id" => id,
        "comments_locked" => true,
        "date" => "2010-04-17 14:00:00.000000Z",
        "deleted" => true,
        "private" => true,
        "total_comments" => 42}
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, timeline_item_path(conn, :create), timeline_item: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update timeline_item" do
    setup [:create_timeline_item]

    test "renders timeline_item when data is valid", %{conn: conn, timeline_item: %TimelineItem{id: id} = timeline_item} do
      conn = put conn, timeline_item_path(conn, :update, timeline_item), timeline_item: @update_attrs
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get conn, timeline_item_path(conn, :show, id)
      assert json_response(conn, 200)["data"] == %{
        "id" => id,
        "comments_locked" => false,
        "date" => "2011-05-18 15:01:01.000000Z",
        "deleted" => false,
        "private" => false,
        "total_comments" => 43}
    end

    test "renders errors when data is invalid", %{conn: conn, timeline_item: timeline_item} do
      conn = put conn, timeline_item_path(conn, :update, timeline_item), timeline_item: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete timeline_item" do
    setup [:create_timeline_item]

    test "deletes chosen timeline_item", %{conn: conn, timeline_item: timeline_item} do
      conn = delete conn, timeline_item_path(conn, :delete, timeline_item)
      assert response(conn, 204)
      assert_error_sent 404, fn ->
        get conn, timeline_item_path(conn, :show, timeline_item)
      end
    end
  end

  defp create_timeline_item(_) do
    timeline_item = fixture(:timeline_item)
    {:ok, timeline_item: timeline_item}
  end
end
