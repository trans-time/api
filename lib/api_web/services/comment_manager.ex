import Ecto.Query

defmodule ApiWeb.Services.CommentManager do
  alias Api.Timeline.{Comment, Post}
  alias Ecto.Multi

  def delete(record) do
    changeset = Comment.changeset(record, %{})
    |> Ecto.Changeset.cast(%{deleted: true}, [:deleted])

    Multi.new
    |> Multi.update_all(:commentable, get_commentable(record), inc: [comment_count: -1])
    |> Multi.update(:comment, changeset)
  end

  def insert(attributes) do
    changeset = Comment.changeset(%Comment{}, attributes)

    Multi.new
    |> Multi.update_all(:commentable, get_commentable(attributes), inc: [comment_count: 1])
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
