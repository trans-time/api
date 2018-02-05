defmodule Api.Timeline.Post do
  use Ecto.Schema
  import Ecto.Changeset
  alias Api.Timeline.{Image, Post, TimelineItem}


  schema "posts" do
    field :nsfw, :boolean, default: false
    field :text, :string

    has_many :images, Image
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
