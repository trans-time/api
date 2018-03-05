defmodule Api.Timeline.Comment do
  use Ecto.Schema
  import Ecto.Changeset
  alias Api.Accounts.User
  alias Api.Timeline.{Comment, Post, Reaction, TimelineItem}


  schema "comments" do
    field :deleted, :boolean, default: false
    field :deleted_by_moderator, :boolean, default: false
    field :ignore_flags, :boolean, default: false
    field :text, :string
    field :under_moderation, :boolean, default: false
    field :moon_count, :integer, default: 0
    field :star_count, :integer, default: 0
    field :sun_count, :integer, default: 0

    belongs_to :user, User
    belongs_to :post, Post
    belongs_to :parent, Comment
    has_many :children, Comment, foreign_key: :parent_id
    has_many :reactions, Reaction

    timestamps()
  end

  @doc false
  def changeset(%Comment{} = comment, attrs) do
    comment
    |> cast(attrs, [:parent_id, :post_id, :text, :user_id])
    |> validate_required([:text])
    |> assoc_constraint(:parent)
    |> assoc_constraint(:post)
    |> assoc_constraint(:user)
  end
end
