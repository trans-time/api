import Ecto.Query

defmodule Api.Moderation.ModerationReport do
  use Ecto.Schema
  import Ecto.Changeset
  alias Api.Accounts.User
  alias Api.Moderation.{Flag, ModerationReport}
  alias Api.Timeline.{Comment, Post}


  schema "moderation_reports" do
    field :moderator_comment, :string
    field :resolved, :boolean, default: false
    field :was_violation, :boolean, default: false
    field :action_banned_user, :boolean, default: false
    field :action_deleted_flaggable, :boolean, default: false
    field :action_ignore_flags, :boolean, default: false
    field :action_lock_comments, :boolean, default: false
    field :ban_user_until, :date
    field :lock_comments_until, :date

    belongs_to :comment, Comment
    belongs_to :post, Post
    belongs_to :indicted, User, foreign_key: :indicted_id
    belongs_to :moderator, User, foreign_key: :moderator_id
    has_many :flags, Flag

    timestamps()
  end

  @doc false
  def changeset(%ModerationReport{} = user, attrs) do
    user
    |> cast(attrs, [
      :moderator_comment, :resolved, :was_violation,
      :action_banned_user, :action_deleted_flaggable, :action_ignore_flags, :action_lock_comments,
      :ban_user_until, :lock_comments_until,
      :comment_id, :post_id, :indicted_id, :moderator_id
    ])
    |> validate_required([:resolved, :was_violation, :action_banned_user, :action_deleted_flaggable, :action_ignore_flags, :action_lock_comments])
  end
end
