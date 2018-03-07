import Ecto.Query

defmodule ApiWeb.Services.CommentManager do
  alias Api.Timeline.{Comment, Post}
  alias Ecto.Multi

  def delete(record) do
    changeset = Comment.private_changeset(record, %{deleted: true, comment_count: 0})

    comment_count_change = 1 + record.comment_count

    Multi.new
    |> Multi.update_all(:commentable, get_commentable(record), inc: [comment_count: -comment_count_change])
    |> Multi.update_all(:parent, Ecto.assoc(record, :parent), inc: [comment_count: -1])
    |> Multi.update_all(:children, Ecto.assoc(record, :children) |> where(deleted: false), set: [deleted: true, deleted_with_parent: true])
    |> Multi.update(:comment, changeset)
  end

  def insert(attributes) do
    changeset = Comment.changeset(%Comment{}, attributes)

    Multi.new
    |> Multi.update_all(:commentable, get_commentable(attributes), inc: [comment_count: 1])
    |> Multi.update_all(:parent, Comment |> where(id: ^attributes["parent_id"]), inc: [comment_count: 1])
    |> Multi.insert(:comment, changeset)
  end

  def update(record, attributes) do
    changeset = Comment.changeset(record, attributes)

    Multi.new
    |> Multi.update(:comment, changeset)
  end

  defp get_commentable(comment) do
    indifferent_comment = Indifferent.access(comment)

    cond do
      indifferent_comment[:post_id] -> Post |> where(id: ^indifferent_comment[:post_id])
    end
  end
end