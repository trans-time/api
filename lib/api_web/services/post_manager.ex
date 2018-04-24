import Ecto.Query

defmodule ApiWeb.Services.PostManager do
  alias Api.Moderation.TextVersion
  alias Api.Profile.UserProfile
  alias Api.Timeline.{Post, TimelineItem}
  alias ApiWeb.Services.Libra
  alias Ecto.Multi

  def delete(record, timeline_item, attributes) do
    post_changeset = Post.private_changeset(record, Map.merge(%{deleted: true}, attributes))
    timeline_item_changeset = TimelineItem.private_changeset(timeline_item, %{deleted: true})

    Multi.new
    |> Multi.update_all(:user_profile, UserProfile |> where(user_id: ^timeline_item.user_id), inc: [post_count: -1])
    |> Multi.update(:timeline_item, timeline_item_changeset)
    |> Multi.update(:post, post_changeset)
  end

  def undelete(record, timeline_item, attributes) do
    post_changeset = Post.private_changeset(record, attributes)
    timeline_item_changeset = TimelineItem.private_changeset(timeline_item, attributes)

    Multi.new
    |> Multi.update_all(:user_profile, UserProfile |> where(user_id: ^timeline_item.user_id), inc: [post_count: 1])
    |> Multi.update(:timeline_item, timeline_item_changeset)
    |> Multi.update(:post, post_changeset)
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
    |> Multi.run(:libra, fn %{post: post} ->
      Libra.review(post, post.text)
    end)
  end

  def update(record, attributes) do
    post_changeset = Post.changeset(record, attributes)
    post_private_changeset = Post.private_changeset(record, %{ignore_flags: false})
    text_version_changeset = TextVersion.changeset(%TextVersion{}, %{
      text: record.text,
      attribute: "text",
      post_id: record.id
    })

    Multi.new
    |> Multi.update(:post, Ecto.Changeset.merge(post_changeset, post_private_changeset))
    |> Multi.run(:text_version, fn %{} ->
      if (Map.has_key?(post_changeset.changes, :text)), do: Api.Repo.insert(text_version_changeset), else: {:ok, record}
    end)
    |> Multi.run(:libra, fn %{post: post} ->
      Libra.review(post, post.text)
    end)
  end
end
