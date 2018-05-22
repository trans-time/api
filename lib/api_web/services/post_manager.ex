import Ecto.Query

defmodule ApiWeb.Services.PostManager do
  alias Api.Moderation.TextVersion
  alias Api.Accounts.User
  alias Api.Profile.{UserProfile, UserTagSummary, UserTagSummaryTag, UserTagSummaryUser}
  alias Api.Timeline.{Post, Tag, TimelineItem}
  alias ApiWeb.Services.{Libra, TimelineItemManager, TimelineItemWatchManager}
  alias ApiWeb.Services.Notifications.NotificationTimelineItemAtManager
  alias Ecto.Multi

  def delete(record, timeline_item, attributes) do
    Multi.new
    |> Multi.run(:timelineable, fn _ ->
      {:ok, record}
    end)
    |> Multi.append(TimelineItemManager.delete(timeline_item, attributes))
    |> Multi.append(delete_notifications(timeline_item))
  end

  def undelete(record, timeline_item, attributes) do
    Multi.new
    |> Multi.run(:timelineable, fn _ ->
      {:ok, record}
    end)
    |> Multi.append(TimelineItemManager.undelete(timeline_item, attributes))
    |> Multi.append(insert_notifications(timeline_item))
  end

  def insert(attributes, user) do
    post_changeset = Post.changeset(%Post{}, attributes)
    tags = gather_tags("#", Map.get(post_changeset.changes, :text))
    users = gather_tags("@", Map.get(post_changeset.changes, :text))

    TimelineItemManager.insert(attributes, tags, users, user)
    |> Multi.run(:timelineable, fn %{timeline_item: timeline_item} ->
      Api.Repo.insert(Ecto.Changeset.merge(post_changeset, Post.private_changeset(%Post{}, %{"timeline_item_id" => timeline_item.id})))
    end)
    |> Multi.merge(fn %{timeline_item: timeline_item} ->
      TimelineItemWatchManager.insert(timeline_item, user)
    end)
    |> Multi.append(Libra.review(attributes["text"]))
    |> Multi.merge(fn
      %{:libra_has_infractions => true} -> Multi.new
      %{timeline_item: timeline_item} -> insert_notifications(timeline_item)
    end)
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

      old_tags = gather_tags("#", Map.get(record, :text))
      current_tags = gather_tags("#", Map.get(post_changeset.changes, :text))
      old_users = gather_tags("@", Map.get(record, :text))
      current_users = gather_tags("@", Map.get(post_changeset.changes, :text))

      Multi.new
      |> Multi.update(:timelineable, post_changeset)
      |> Multi.run(:text_version, fn %{} ->
        Api.Repo.insert(text_version_changeset)
      end)
      |> Multi.append(TimelineItemManager.update(timeline_item, attributes, old_tags, current_tags, old_users, current_users, user))
      |> Multi.append(Libra.review(attributes["text"]))
      |> Multi.merge(fn
        %{:libra_has_infractions => true} -> delete_notifications(timeline_item)
        _ -> NotificationTimelineItemAtManager.insert_added_delete_removed(timeline_item, Map.get(record, :text), Map.get(post_changeset.changes, :text))
      end)
    else
      old_tags = gather_tags("#", Map.get(record, :text))
      old_users = gather_tags("@", Map.get(record, :text))

      Multi.new
      |> Multi.update(:timelineable, post_changeset)
      |> Multi.append(TimelineItemManager.update(timeline_item, attributes, old_tags, old_tags, old_users, old_users, user))
    end
  end

  def insert_notifications(timeline_item) do
    timeline_item = Api.Repo.preload(timeline_item, [:post])
    
    Multi.new
    |> Multi.append(NotificationTimelineItemAtManager.insert_all(timeline_item))
  end

  def delete_notifications(timeline_item) do
    timeline_item = Api.Repo.preload(timeline_item, [:post])

    Multi.new
    |> Multi.append(NotificationTimelineItemAtManager.delete_all(timeline_item))
  end

  def gather_tags(leading_char, text \\ "") do
    text = text || ""
    Enum.filter(Enum.uniq(List.flatten(Regex.scan(Regex.compile!("#{leading_char}([a-zA-Z0-9_]+)"), text))), fn (item) -> String.at(item, 0) != leading_char end)
  end
end
