defmodule Api.Timeline.Post do
  use Ecto.Schema
  import Ecto.Changeset
  alias Api.Timeline.{Comment, Image, Post, Reaction, TimelineItem}


  schema "posts" do
    field :nsfw, :boolean, default: false
    field :text, :string
    field :total_moons, :integer, default: 0
    field :total_stars, :integer, default: 0
    field :total_suns, :integer, default: 0
    field :total_comments, :integer, default: 0

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
