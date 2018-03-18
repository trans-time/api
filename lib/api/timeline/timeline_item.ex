defmodule Api.Timeline.TimelineItem do
  use Ecto.Schema
  import Ecto.Changeset
  alias Api.Timeline.{Post, Tag, TimelineItem}
  alias Api.Accounts.User


  schema "timeline_items" do
    field :comments_locked, :boolean, default: false
    field :date, :utc_datetime
    field :deleted, :boolean, default: false
    field :deleted_by_moderator, :boolean, default: false
    field :ignore_flags, :boolean, default: false
    field :private, :boolean, default: false
    field :under_moderation, :boolean, default: false

    many_to_many :tags, Tag, join_through: "timeline_items_tags"
    many_to_many :users, User, join_through: "timeline_items_users"
    belongs_to :user, User

    belongs_to :post, Post

    timestamps()
  end

  @doc false
  def changeset(%TimelineItem{} = timeline_item, attrs) do
    timeline_item
    |> cast(attrs, [:date, :private, :user_id])
    |> validate_required([:date])
    |> assoc_constraint(:user)
  end

  @doc false
  def private_changeset(%TimelineItem{} = timeline_item, attrs) do
    timeline_item
    |> cast(attrs, [:deleted])
  end
end
