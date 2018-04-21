defmodule Api.Timeline.Post do
  use Ecto.Schema
  import Ecto.Changeset
  alias Api.Moderation.{ModerationReport, TextVersion}
  alias Api.Timeline.{Comment, Image, Post, Reaction, TimelineItem}


  schema "posts" do
    field :nsfw, :boolean, default: false
    field :text, :string
    field :moon_count, :integer, default: 0
    field :star_count, :integer, default: 0
    field :sun_count, :integer, default: 0
    field :comment_count, :integer, default: 0
    field :comments_are_locked, :boolean, default: false
    field :deleted, :boolean, default: false
    field :deleted_by_moderator, :boolean, default: false
    field :deleted_by_user, :boolean, default: false
    field :ignore_flags, :boolean, default: false
    field :under_moderation, :boolean, default: false

    has_many :comments, Comment
    has_many :images, Image
    has_many :moderation_reports, ModerationReport
    has_many :reactions, Reaction
    has_one :timeline_item, TimelineItem
    has_many :text_versions, TextVersion

    timestamps()
  end

  @doc false
  def changeset(%Post{} = post, attrs) do
    post
    |> cast(attrs, [:nsfw, :text])
    |> validate_required([:nsfw])
  end

  @doc false
  def private_changeset(%Post{} = post, attrs) do
    post
    |> cast(attrs, [:comments_are_locked, :deleted, :deleted_by_moderator, :deleted_by_user, :ignore_flags, :under_moderation])
  end
end
