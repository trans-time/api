defmodule Api.Timeline.Comment do
  use Api.Schema
  import Ecto.Changeset
  alias Api.Accounts.User
  alias Api.Moderation.{ModerationReport, TextVersion}
  alias Api.Timeline.{Comment, Post, Reaction, TimelineItem}


  schema "comments" do
    field :deleted, :boolean, default: false
    field :deleted_by_moderator, :boolean, default: false
    field :deleted_by_user, :boolean, default: false
    field :deleted_with_parent, :boolean, default: false
    field :ignore_flags, :boolean, default: false
    field :text, :string
    field :under_moderation, :boolean, default: false
    field :comment_count, :integer, default: 0
    field :moon_count, :integer, default: 0
    field :star_count, :integer, default: 0
    field :sun_count, :integer, default: 0

    belongs_to :user, User
    belongs_to :post, Post
    belongs_to :parent, Comment
    has_many :children, Comment, foreign_key: :parent_id
    has_many :moderation_reports, ModerationReport
    has_many :reactions, Reaction
    has_many :text_versions, TextVersion

    timestamps()
  end

  @doc false
  def changeset(%Comment{} = comment, attrs) do
    comment
    |> cast(attrs, [:parent_id, :post_id, :text, :user_id])
    |> validate_required([:text])
    |> validate_length(:text, max: 8000, message: "remote.errors.detail.length.length")
    |> assoc_constraint(:parent)
    |> assoc_constraint(:post)
    |> assoc_constraint(:user)
    |> validate_that_comments_are_unlocked(:post_id)
  end

  @doc false
  def private_changeset(%Comment{} = comment, attrs) do
    comment
    |> cast(attrs, [:comment_count, :deleted, :deleted_by_moderator, :deleted_by_user, :deleted_with_parent, :ignore_flags, :under_moderation])
  end

  def validate_that_comments_are_unlocked(changeset, field, options \\ []) do
    validate_change(changeset, field, fn _, assoc_id ->
      case Api.Repo.get(Post, assoc_id).comments_are_locked do
        true -> [{field, options[:message] || "remote.errors.detail.forbidden.commentsAreLocked"}]
        false -> []
      end
    end)
  end
end
