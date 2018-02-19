defmodule Api.Timeline.Comment do
  use Ecto.Schema
  import Ecto.Changeset
  alias Api.Accounts.User
  alias Api.Timeline.{Comment, Post, TimelineItem}


  schema "comments" do
    field :deleted, :boolean, default: false
    field :text, :string
    field :moon_count, :integer, default: 0
    field :star_count, :integer, default: 0
    field :sun_count, :integer, default: 0
    field :comment_count, :integer, default: 0

    belongs_to :user, User
    belongs_to :post, Post
    belongs_to :parent, Comment
    has_many :children, Comment, foreign_key: :parent_id

    timestamps()
  end

  @doc false
  def changeset(%Comment{} = comment, attrs) do
    comment
    |> cast(attrs, [:deleted, :text])
    |> validate_required([:deleted, :text])
    |> prepare_changes(fn (changeset) ->
      Ecto.assoc(changeset.data, :post)
      |> Repo.update_all(inc: [comment_count: 1])

      Ecto.assoc(changeset.data, :parent)
      |> Repo.update_all(inc: [comment_count: 1])

      changeset
    end)
  end
end
