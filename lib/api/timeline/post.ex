defmodule Api.Timeline.Post do
  use Api.Schema
  import Ecto.Changeset
  alias Api.Moderation.{ModerationReport, TextVersion}
  alias Api.Timeline.{Comment, Image, Post, Reaction, TimelineItem}


  schema "posts" do
    field :text, :string

    has_many :images, Image
    has_one :timeline_item, TimelineItem
    has_many :text_versions, TextVersion

    timestamps()
  end

  @doc false
  def changeset(%Post{} = post, attrs) do
    post
    |> cast(attrs, [:text])
  end
end
