defmodule Api.Timeline.Post do
  use Ecto.Schema
  import Ecto.Changeset
  alias Api.Timeline.{Comment, Image, Post, Reaction, TimelineItem}


  schema "posts" do
    field :nsfw, :boolean, default: false
    field :text, :string
    field :moon_count, :integer, default: 0
    field :star_count, :integer, default: 0
    field :sun_count, :integer, default: 0
    field :comment_count, :integer, default: 0

    has_many :comments, Comment
    has_many :images, Image
    has_many :reactions, {"posts_reactions", Reaction}, foreign_key: :reactable_id
    has_one :timeline_item, TimelineItem

    timestamps()
  end

  @doc false
  def changeset(%Post{} = post, attrs) do
    post
    |> cast(attrs, [:nsfw, :text])
    |> validate_required([:nsfw, :text])
  end
end
