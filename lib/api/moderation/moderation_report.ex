import Ecto.Query

defmodule Api.Moderation.ModerationReport do
  use Api.Schema
  import Ecto.Changeset
  alias Api.Accounts.User
  alias Api.Moderation.{Flag, ModerationReport, Verdict}
  alias Api.Timeline.{Comment, TimelineItem}


  schema "moderation_reports" do
    field :moderator_comment, :string
    field :was_violation, :boolean, default: false
    field :resolved, :boolean, default: false
    field :should_ignore, :boolean, default: false

    belongs_to :comment, Comment
    belongs_to :timeline_item, TimelineItem
    belongs_to :indicted, User, foreign_key: :indicted_id
    has_many :flags, Flag
    has_many :verdicts, Verdict

    timestamps()
  end

  @doc false
  def changeset(%ModerationReport{} = user, attrs) do
    user
    |> cast(attrs, [:moderator_comment, :resolved, :was_violation, :comment_id, :timeline_item_id, :indicted_id])
    |> validate_required([:resolved, :was_violation])
    |> assoc_constraint(:comment)
    |> assoc_constraint(:timeline_item)
    |> assoc_constraint(:indicted)
  end
end
