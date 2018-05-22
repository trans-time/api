import Ecto.Query

defmodule ApiWeb.Services.CommentManager do
  alias Api.Moderation.TextVersion
  alias Api.Timeline.{Comment, TimelineItem}
  alias ApiWeb.Services.{Libra, TimelineItemWatchManager}
  alias ApiWeb.Services.Notifications.{NotificationCommentAtManager, NotificationCommentManager}
  alias Ecto.Multi

  def delete(record, attributes) do
    changeset = Comment.private_changeset(record, Map.merge(%{deleted: true, deleted_at: DateTime.utc_now(), comment_count: 0}, attributes))

    comment_count_change = 1 + record.comment_count

    Multi.new
    |> Multi.update_all(:commentable, get_commentable(record), inc: [comment_count: -comment_count_change])
    |> Multi.update_all(:parent, Ecto.assoc(record, :parent), inc: [comment_count: -1])
    |> Multi.update_all(:children, Ecto.assoc(record, :children) |> where(deleted: false), set: [deleted: true, deleted_with_parent: true])
    |> Multi.update(:comment, changeset)
    |> Multi.append(delete_notifications(record))
  end

  def undelete(record, attributes) do
    deleted_children = Api.Repo.all(from c in Comment, where: c.parent_id == ^record.id and c.deleted_with_parent == ^true and c.deleted_by_moderator == ^false and c.deleted_by_user == ^false)
    comment_count = Kernel.length(deleted_children)
    changeset = Comment.private_changeset(record, Map.merge(attributes, %{comment_count: comment_count}))

    Multi.new
    |> Multi.update_all(:commentable, get_commentable(record), inc: [comment_count: comment_count + 1])
    |> Multi.update_all(:parent, Ecto.assoc(record, :parent), inc: [comment_count: 1])
    |> Multi.update_all(:children, Ecto.assoc(record, :children) |> where(deleted_with_parent: true, deleted_by_moderator: false, deleted_by_user: false), set: [deleted: false, deleted_with_parent: false])
    |> Multi.update(:comment, changeset)
    |> Multi.append(insert_notifications(record))
  end

  def insert(attributes, user) do
    changeset = Comment.public_insert_changeset(%Comment{}, attributes)
    commentable_query = get_commentable(attributes)
    commentable = Api.Repo.one(commentable_query)

    Multi.new
    |> Multi.update_all(:commentable, commentable_query, inc: [comment_count: 1])
    |> Multi.update_all(:parent, Comment |> where(id: ^attributes["parent_id"]), inc: [comment_count: 1])
    |> Multi.insert(:comment, changeset)
    |> Multi.append(TimelineItemWatchManager.insert(commentable, user))
    |> Multi.append(Libra.review(attributes["text"]))
    |> Multi.merge(fn
      %{:libra_has_infractions => true} -> Multi.new
      %{comment: comment} -> insert_notifications(comment)
    end)
    # |> Multi.append(NotificationCommentManager.insert(commentable, user))
  end

  def update(record, attributes) do
    comment_changeset = Comment.public_update_changeset(record, attributes)
    comment_private_changeset = Comment.private_changeset(record, %{ignore_flags: false})
    text_version_changeset = TextVersion.changeset(%TextVersion{}, %{
      text: record.text,
      attribute: "text",
      comment_id: record.id
    })

    Multi.new
    |> Multi.update(:comment, Ecto.Changeset.merge(comment_changeset, comment_private_changeset))
    |> Multi.run(:text_version, fn %{} ->
      if (Map.has_key?(comment_changeset.changes, :text)), do: Api.Repo.insert(text_version_changeset), else: {:ok, record}
    end)
    |> Multi.append(Libra.review(attributes["text"]))
    |> Multi.merge(fn
      %{:libra_has_infractions => true} -> delete_notifications(record)
      _ -> NotificationCommentAtManager.insert_added_delete_removed(record, Map.get(record, :text), Map.get(comment_changeset.changes, :text))
    end)
  end

  def insert_notifications(comment) do
    Api.Repo.preload(comment, [timeline_item: [:watchers]])

    Multi.new
    |> Multi.append(NotificationCommentAtManager.insert_all(comment))
    |> Multi.append(NotificationCommentManager.insert(comment))
  end

  def delete_notifications(comment) do
    Api.Repo.preload(comment, [:timeline_item])

    Multi.new
    |> Multi.append(NotificationCommentAtManager.delete_all(comment))
    |> Multi.append(NotificationCommentManager.delete(comment))
  end

  defp get_commentable(comment) do
    indifferent_comment = Indifferent.access(comment)

    cond do
      indifferent_comment[:timeline_item_id] -> TimelineItem |> where(id: ^indifferent_comment[:timeline_item_id])
    end
  end
end
