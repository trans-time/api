defmodule Api.Timeline.TimelineItem do
  use Api.Schema
  import Ecto.Changeset
  alias Api.Moderation.{ModerationReport}
  alias Api.Timeline.{Comment, Image, Post, Reaction, Tag, TimelineItem}
  alias Api.Accounts.User
  alias Api.Notifications.{NotificationTimelineItemAt}


  schema "timeline_items" do
    field :date, :utc_datetime
    field :moon_count, :integer, default: 0
    field :star_count, :integer, default: 0
    field :sun_count, :integer, default: 0
    field :reaction_count, :integer, default: 0
    field :comment_count, :integer, default: 0
    field :comments_are_locked, :boolean, default: false
    field :is_marked_for_deletion, :boolean, default: false
    field :is_marked_for_deletion_by_moderator, :boolean, default: false
    field :is_marked_for_deletion_by_user, :boolean, default: false
    field :marked_for_deletion_on, :utc_datetime
    field :is_ignoring_flags, :boolean, default: false
    field :is_private, :boolean, default: false
    field :is_under_moderation, :boolean, default: false

    many_to_many :tags, Tag, join_through: "timeline_items_tags", on_replace: :delete
    many_to_many :users, User, join_through: "timeline_items_users", on_replace: :delete
    many_to_many :watchers, User, join_through: "timeline_item_watchers", join_keys: [watched_id: :id, watcher_id: :id]
    has_many :comments, Comment
    has_many :moderation_reports, ModerationReport
    has_many :reactions, Reaction
    belongs_to :user, User

    has_one :post, Post

    has_many :notification_timeline_item_ats, NotificationTimelineItemAt

    timestamps()
  end

  @doc false
  def changeset(%TimelineItem{} = timeline_item, attrs) do
    timeline_item
    |> cast(attrs, [:date, :is_private, :user_id])
    |> validate_required([:date, :is_private])
    |> assoc_constraint(:user)
  end

  @doc false
  def private_changeset(%TimelineItem{} = post, attrs) do
    post
    |> cast(attrs, [:comments_are_locked, :is_marked_for_deletion, :is_marked_for_deletion_by_moderator, :is_marked_for_deletion_by_user, :marked_for_deletion_on, :is_ignoring_flags, :is_under_moderation])
  end
end
