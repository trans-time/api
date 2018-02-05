defmodule Api.Timeline.TimelineItem do
  use Ecto.Schema
  import Ecto.Changeset
  alias Api.Timeline.{Post, Tag, TimelineItem}
  alias Api.Accounts.User


  schema "timeline_items" do
    field :comments_locked, :boolean, default: false
    field :date, :utc_datetime
    field :deleted, :boolean, default: false
    field :private, :boolean, default: false
    field :total_comments, :integer

    belongs_to :user, User
    many_to_many :tags, Tag, join_through: "timeline_items_tags"
    many_to_many :users, User, join_through: "timeline_items_users"

    belongs_to :post, Post

    timestamps()
  end

  @doc false
  def changeset(%TimelineItem{} = timeline_item, attrs) do
    timeline_item
    |> cast(attrs, [:comments_locked, :date, :deleted, :private, :total_comments])
    |> validate_required([:comments_locked, :date, :deleted, :private, :total_comments])
  end
end
