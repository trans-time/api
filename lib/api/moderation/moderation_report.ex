import Ecto.Query

defmodule Api.Moderation.ModerationReport do
  use Ecto.Schema
  import Ecto.Changeset
  alias Api.Accounts.User
  alias Api.Moderation.{Flag, ModerationReport, Verdict}
  alias Api.Timeline.{Comment, Post}


  schema "moderation_reports" do
    field :moderator_comment, :string
    field :was_violation, :boolean, default: false
    field :resolved, :boolean, default: false

    belongs_to :comment, Comment
    belongs_to :post, Post
    belongs_to :indicted, User, foreign_key: :indicted_id
    has_many :flags, Flag
    has_many :verdicts, Verdict

    timestamps()
  end

  @doc false
  def changeset(%ModerationReport{} = user, attrs) do
    user
    |> cast(attrs, [:moderator_comment, :resolved, :was_violation, :comment_id, :post_id, :indicted_id])
    |> validate_required([:resolved, :was_violation])
  end
end
