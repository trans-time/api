defmodule Api.Timeline.Comment do
  use Api.Schema
  import Ecto.Changeset
  alias Api.Accounts.User
  alias Api.Moderation.{ModerationReport, TextVersion}
  alias Api.Timeline.{Comment, Reaction, TimelineItem}


  schema "comments" do
    field :deleted, :boolean, default: false
    field :deleted_by_moderator, :boolean, default: false
    field :deleted_by_user, :boolean, default: false
    field :deleted_with_parent, :boolean, default: false
    field :deleted_at, :utc_datetime
    field :ignore_flags, :boolean, default: false
    field :text, :string
    field :under_moderation, :boolean, default: false
    field :comment_count, :integer, default: 0
    field :moon_count, :integer, default: 0
    field :star_count, :integer, default: 0
    field :sun_count, :integer, default: 0

    belongs_to :user, User
    belongs_to :timeline_item, TimelineItem
    belongs_to :parent, Comment
    has_many :children, Comment, foreign_key: :parent_id
    has_many :moderation_reports, ModerationReport
    has_many :reactions, Reaction
    has_many :text_versions, TextVersion

    timestamps()
  end

  @doc false
  def public_insert_changeset(%Comment{} = comment, attrs) do
    comment
    |> cast(attrs, [:parent_id, :timeline_item_id, :user_id])
    |> assoc_constraint(:parent)
    |> assoc_constraint(:timeline_item)
    |> assoc_constraint(:user)
    |> public_update_changeset(attrs)
  end

  @doc false
  def public_update_changeset(comment, attrs) do
    comment
    |> cast(attrs, [:text])
    |> validate_required([:text])
    |> validate_length(:text, max: 8000, message: "remote.errors.detail.length.length")
    |> validate_that_comments_are_unlocked(:timeline_item_id)
  end

  @doc false
  def private_changeset(%Comment{} = comment, attrs) do
    comment
    |> cast(attrs, [:comment_count, :deleted, :deleted_by_moderator, :deleted_by_user, :deleted_with_parent, :deleted_at, :ignore_flags, :under_moderation])
  end

  def validate_that_comments_are_unlocked(changeset, field, options \\ []) do
    validate_change(changeset, field, fn _, assoc_id ->
      case Api.Repo.get(TimelineItem, assoc_id).comments_are_locked do
        true -> [{field, options[:message] || "remote.errors.detail.forbidden.commentsAreLocked"}]
        false -> []
      end
    end)
  end
end
