import Ecto.Query

defmodule ApiWeb.Services.PostManager do
  alias Api.Moderation.TextVersion
  alias Api.Accounts.User
  alias Api.Profile.{UserProfile, UserTagSummary, UserTagSummaryTag, UserTagSummaryUser}
  alias Api.Timeline.{Post, Tag, TimelineItem}
  alias ApiWeb.Services.{Libra, TimelineItemManager}
  alias Ecto.Multi

  def delete(record, timeline_item, attributes) do
    timeline_item_multi = TimelineItemManager.delete(timeline_item, attributes)
    post_multi = Multi.new
    |> Multi.run(:timelineable, fn _ ->
      {:ok, record}
    end)

    Multi.append(post_multi, timeline_item_multi)
  end

  def undelete(record, timeline_item, attributes) do
    timeline_item_multi = TimelineItemManager.undelete(timeline_item, attributes)
    post_multi = Multi.new
    |> Multi.run(:timelineable, fn _ ->
      {:ok, record}
    end)

    Multi.append(post_multi, timeline_item_multi)
  end

  def insert(attributes, user) do
    post_changeset = Post.changeset(%Post{}, attributes)
    tags = gather_tags(post_changeset.changes.text, "#")
    users = gather_tags(post_changeset.changes.text, "@")

    post_multi = Multi.new
    |> Multi.insert(:timelineable, post_changeset)
    timeline_item_multi = TimelineItemManager.insert(attributes, tags, users, user)
    libra_multi = Multi.new
    |> Multi.run(:libra, fn %{timelineable: timelineable, timeline_item: timeline_item} ->
      Libra.review(timeline_item, timelineable.text)
    end)

    Multi.append(post_multi, Multi.append(timeline_item_multi, libra_multi))
  end

  def update(record, attributes, user) do
    record = Api.Repo.preload(record, [:timeline_item])
    timeline_item = record.timeline_item
    post_changeset = Post.changeset(record, attributes)

    if Map.has_key?(post_changeset.changes, :text) do
      text_version_changeset = TextVersion.changeset(%TextVersion{}, %{
        text: record.text,
        attribute: "text",
        post_id: record.id
      })

      old_tags = gather_tags(record.text, "#")
      current_tags = gather_tags(post_changeset.changes.text, "#")
      old_users = gather_tags(record.text, "@")
      current_users = gather_tags(post_changeset.changes.text, "@")

      post_multi = Multi.new
      |> Multi.update(:timelineable, post_changeset)
      |> Multi.run(:text_version, fn %{} ->
        Api.Repo.insert(text_version_changeset)
      end)
      timeline_item_multi = TimelineItemManager.update(timeline_item, attributes, old_tags, current_tags, old_users, current_users, user)
      libra_multi = Multi.new
      |> Multi.run(:libra, fn %{timelineable: timelineable, timeline_item: timeline_item} ->
        Libra.review(timeline_item, timelineable.text)
      end)

      Multi.append(post_multi, Multi.append(timeline_item_multi, libra_multi))
    else
      old_tags = gather_tags(record.text, "#")
      old_users = gather_tags(record.text, "@")

      post_multi = Multi.new
      |> Multi.update(:timelineable, post_changeset)
      timeline_item_multi = TimelineItemManager.update(timeline_item, attributes, old_tags, old_tags, old_users, old_users, user)

      Multi.append(post_multi, timeline_item_multi)
    end
  end

  def gather_tags(text, leading_char) do
    Enum.filter(Enum.uniq(List.flatten(Regex.scan(Regex.compile!("#{leading_char}([a-zA-Z0-9_]+)"), text))), fn (item) -> String.at(item, 0) != leading_char end)
  end
end
