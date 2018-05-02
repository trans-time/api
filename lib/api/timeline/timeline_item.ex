defmodule Api.Timeline.TimelineItem do
  use Api.Schema
  import Ecto.Changeset
  alias Api.Moderation.{ModerationReport}
  alias Api.Timeline.{Comment, Image, Post, Reaction, Tag, TimelineItem}
  alias Api.Accounts.User


  schema "timeline_items" do
    field :date, :utc_datetime
    field :moon_count, :integer, default: 0
    field :star_count, :integer, default: 0
    field :sun_count, :integer, default: 0
    field :comment_count, :integer, default: 0
    field :comments_are_locked, :boolean, default: false
    field :deleted, :boolean, default: false
    field :deleted_by_moderator, :boolean, default: false
    field :deleted_by_user, :boolean, default: false
    field :ignore_flags, :boolean, default: false
    field :nsfw, :boolean, default: false
    field :nsfw_butt, :boolean, default: false
    field :nsfw_genitals, :boolean, default: false
    field :nsfw_nipples, :boolean, default: false
    field :nsfw_underwear, :boolean, default: false
    field :private, :boolean, default: false
    field :under_moderation, :boolean, default: false

    many_to_many :tags, Tag, join_through: "timeline_items_tags", on_replace: :delete
    many_to_many :users, User, join_through: "timeline_items_users", on_replace: :delete
    has_many :comments, Comment
    has_many :moderation_reports, ModerationReport
    has_many :reactions, Reaction
    belongs_to :user, User

    belongs_to :post, Post

    timestamps()
  end

  @doc false
  def changeset(%TimelineItem{} = timeline_item, attrs) do
    timeline_item
    |> cast(attrs, [:date, :nsfw, :private, :user_id])
    |> validate_required([:date, :nsfw, :private])
    |> validate_that_date_is_not_in_the_future(:date)
    |> assoc_constraint(:user)
  end

  @doc false
  def private_changeset(%TimelineItem{} = post, attrs) do
    post
    |> cast(attrs, [:comments_are_locked, :deleted, :deleted_by_moderator, :deleted_by_user, :ignore_flags, :under_moderation])
  end

  def validate_that_date_is_not_in_the_future(changeset, field, options \\ []) do
    validate_change(changeset, field, fn _, datetime ->
      case DateTime.compare(datetime, DateTime.utc_now()) == :gt do
        true -> [{field, options[:message] || "remote.errors.detail.invalid.dateAfterNow"}]
        false -> []
      end
    end)
  end
end
