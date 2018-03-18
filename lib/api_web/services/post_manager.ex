import Ecto.Query

defmodule ApiWeb.Services.PostManager do
  alias Api.Profile.UserProfile
  alias Api.Timeline.{Post, TimelineItem}
  alias Ecto.Multi

  def delete(record, timeline_item) do
    changeset = TimelineItem.private_changeset(timeline_item, %{deleted: true})

    Multi.new
    |> Multi.update_all(:user_profile, UserProfile |> where(user_id: ^timeline_item.user_id), inc: [post_count: -1])
    |> Multi.update(:timeline_item, changeset)
    |> Multi.run(:post, fn (_) ->
      {:ok, record}
    end)
  end

  def insert(attributes) do
    post_changeset = Post.changeset(%Post{}, attributes)
    timeline_item_changeset = TimelineItem.changeset(%TimelineItem{}, %{
      date: attributes["date"],
      user_id: attributes["user_id"]
    })

    Multi.new
    |> Multi.update_all(:user_profile, Ecto.assoc(Api.Accounts.get_user!(attributes["user_id"]), :user_profile), inc: [post_count: 1])
    |> Multi.insert(:post, post_changeset)
    |> Multi.run(:timeline_item, fn %{post: post} ->
      Api.Repo.insert_or_update(Ecto.Changeset.change(timeline_item_changeset, %{post_id: post.id}))
    end)
  end

  def update(record, attributes) do
    changeset = Post.changeset(record, attributes)

    Multi.new
    |> Multi.update(:post, changeset)
  end
end
