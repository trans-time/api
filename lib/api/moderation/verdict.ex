import Ecto.Query

defmodule Api.Moderation.Verdict do
  use Api.Schema
  import Ecto.Changeset
  alias Api.Accounts.User
  alias Api.Moderation.{ModerationReport, Verdict}


  schema "verdicts" do
    field :moderator_comment, :string
    field :was_violation, :boolean, default: false
    field :action_banned_user, :boolean, default: false
    field :action_deleted_flaggable, :boolean, default: false
    field :action_ignore_flags, :boolean, default: false
    field :action_lock_comments, :boolean, default: false
    field :action_change_maturity_rating, :integer
    field :action_delete_media, :boolean, default: false
    field :delete_image_ids, {:array, :integer}, default: []
    field :ban_user_until, :utc_datetime
    field :lock_comments_until, :utc_datetime
    field :previous_maturity_rating, :integer

    belongs_to :moderation_report, ModerationReport
    belongs_to :moderator, User, foreign_key: :moderator_id

    timestamps()
  end

  @doc false
  def changeset(%Verdict{} = user, attrs) do
    user
    |> cast(attrs, [
      :moderator_comment, :was_violation,
      :action_banned_user, :action_deleted_flaggable, :action_ignore_flags, :action_lock_comments,
      :action_change_maturity_rating, :previous_maturity_rating,
      :action_delete_media, :delete_image_ids,
      :ban_user_until, :lock_comments_until,
      :moderation_report_id, :moderator_id
    ])
    |> validate_required([
      :was_violation,
      :action_banned_user, :action_deleted_flaggable, :action_ignore_flags, :action_lock_comments,
      :action_delete_media
    ])
    |> assoc_constraint(:moderation_report)
    |> assoc_constraint(:moderator)
  end
end
