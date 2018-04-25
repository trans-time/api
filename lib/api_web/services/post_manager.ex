import Ecto.Query

defmodule ApiWeb.Services.PostManager do
  alias Api.Moderation.TextVersion
  alias Api.Profile.{UserProfile, UserTagSummary}
  alias Api.Timeline.{Post, Tag, TimelineItem}
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
    tags = gather_tags(post_changeset.changes.text)
    tag_records = Api.Repo.all(from t in Tag, where: t.name in ^tags)

    multi = Multi.new
    |> Multi.update_all(:user_profile, Ecto.assoc(Api.Accounts.get_user!(attributes["user_id"]), :user_profile), inc: [post_count: 1])
    |> Multi.insert(:post, post_changeset)
    |> Multi.run(:timeline_item, fn %{post: post} ->
      Api.Repo.insert(Ecto.Changeset.change(timeline_item_changeset, %{post_id: post.id}))
    end)
    Enum.reduce(tags, multi, fn (tag, multi) ->
      multi
      |> Multi.run("find_or_create_#{tag}", fn %{} ->
        tag_record = Enum.find(tag_records, fn (tag_record) -> tag_record.name == tag end)

        if (tag_record != nil), do: {:ok, tag_record}, else: Api.Repo.insert(Tag.changeset(%Tag{}, %{name: tag}))
      end)
    end)
    |> Multi.run(:aggregated_tag_records, fn args ->
      {:ok, Enum.map(tags, fn (tag) -> args["find_or_create_#{tag}"] end)}
    end)
    |> Multi.run(:put_tag_associations, fn %{timeline_item: timeline_item, aggregated_tag_records: aggregated_tag_records} ->
      Api.Repo.preload(timeline_item, :tags)
      |> Ecto.Changeset.change
      |> Ecto.Changeset.put_assoc(:tags, aggregated_tag_records)
      |> Api.Repo.update
    end)
    |> Multi.run(:update_user_tag_summary, fn %{timeline_item: timeline_item, aggregated_tag_records: aggregated_tag_records} ->
      timeline_item = Api.Repo.preload(timeline_item, user: [user_profile: [user_tag_summary: [:tags]]])
      user = timeline_item.user
      user_tag_summary = user.user_profile.user_tag_summary
      user_id = Integer.to_string(user.id)

      summary = Map.put(user_tag_summary.summary, user_id, %{tags: Enum.reduce(aggregated_tag_records, user_tag_summary.summary[user_id]["tags"], fn(tag, tags) ->
        if Map.has_key?(tags, tag.id) do
          Map.put(tags, tag.id, tags[tag.id] ++ [timeline_item.id])
        else
          Map.put(tags, tag.id, [timeline_item.id])
        end
      end),
      users: %{},
      private: (if (timeline_item.private), do: [timeline_item.id | user_tag_summary.summary[user_id]["private"]], else: user_tag_summary.summary[user_id]["private"])})
      UserTagSummary.changeset(user_tag_summary, %{
        summary: summary
      })
      |> Ecto.Changeset.put_assoc(:tags, Enum.uniq(aggregated_tag_records ++ user_tag_summary.tags))
      |> Api.Repo.update
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

  defp gather_tags(text) do
    Enum.filter(Enum.uniq(List.flatten(Regex.scan(~r/#([a-zA-Z0-9_]+)/, text))), fn (item) -> String.at(item, 0) != "#" end)
  end
end
