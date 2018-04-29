import Ecto.Query

defmodule Api.Moderation.Flag do
  use Api.Schema
  import Ecto.Changeset
  alias Api.Accounts.User
  alias Api.Moderation.{Flag, ModerationReport}
  alias Api.Timeline.{Comment, Post}


  schema "flags" do
    field :text, :string
    field :trolling, :boolean, default: false
    field :bot, :boolean, default: false
    field :illicit_activity, :boolean, default: false
    field :unconsenting_image, :boolean, default: false
    field :unmarked_NSFW, :boolean, default: false

    belongs_to :comment, Comment
    belongs_to :post, Post
    belongs_to :user, User
    belongs_to :moderation_report, ModerationReport

    timestamps()
  end

  @doc false
  def changeset(%Flag{} = user, attrs) do
    user
    |> cast(attrs, [:text, :bot, :illicit_activity, :trolling, :unconsenting_image, :unmarked_NSFW, :comment_id, :post_id, :user_id, :moderation_report_id])
    |> validate_required([:bot, :illicit_activity, :trolling, :unconsenting_image, :unmarked_NSFW])
    |> assoc_constraint(:comment)
    |> assoc_constraint(:post)
    |> assoc_constraint(:user)
    |> assoc_constraint(:moderation_report)
  end
end
