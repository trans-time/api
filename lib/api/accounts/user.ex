import Ecto.Query

defmodule Api.Accounts.User do
  use Ecto.Schema
  use Arc.Ecto.Schema
  import Ecto.Changeset
  alias Api.Accounts.{CurrentUser, User}
  alias Api.Moderation.{Flag, ModerationReport}
  alias Api.Profile.{UserIdentity, UserProfile, UserTagSummary}
  alias Api.Relationship.{Block, Follow}
  alias Api.Timeline.{Reaction, TimelineItem}


  schema "users" do
    field :avatar, Api.Profile.Avatar.Type
    field :email, :string
    field :display_name, :string
    field :is_moderator, :boolean, default: false
    field :password, :string
    field :pronouns, :string
    field :username, :string

    has_many :blockeds, Block, foreign_key: :blocker_id
    has_many :blockers, Block, foreign_key: :blocked_id
    has_one :current_user, CurrentUser
    has_many :indictions, ModerationReport, foreign_key: :indicted_id
    has_many :flags, Flag
    has_many :followeds, Follow, foreign_key: :follower_id
    has_many :followers, Follow, foreign_key: :followed_id
    has_many :reactions, Reaction
    has_many :timeline_items, TimelineItem
    has_many :user_identities, UserIdentity
    has_one :user_profile, UserProfile
    many_to_many :user_tag_summaries, UserTagSummary, join_through: "user_tag_summaries_users"

    timestamps()
  end

  def get_user_by_identification(identification) do
    cond do
      String.contains?(identification, "@") ->
        User |> where(email: ^identification) |> Api.Repo.one
      true ->
        User |> where(username: ^identification) |> Api.Repo.one
    end
  end

  def validate_password(user, password) do
    Comeonin.Argon2.checkpw(password, user.password)
  end

  @doc false
  def changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, [:display_name, :email, :password, :pronouns, :username])
    |> cast_attachments(attrs, [:avatar])
    |> validate_required([:email, :password, :username])
    |> validate_length(:display_name, max: 100, message: "remote.errors.detail.length.length")
    |> validate_length(:email, max: 1000, message: "remote.errors.detail.length.length")
    |> validate_format(:email, ~r/^[A-Za-z0-9._%+-+']+@[A-Za-z0-9.-]+\.[A-Za-z]+$/, message: "remote.errors.detail.format.email")
    |> validate_length(:password, max: 1000, message: "remote.errors.detail.length.length")
    |> validate_length(:pronouns, max: 64, message: "remote.errors.detail.length.length")
    |> validate_length(:username, max: 64, message: "remote.errors.detail.length.length")
    |> unique_constraint(:email)
    |> unique_constraint(:username)
    |> put_pass_hash()
  end

  defp put_pass_hash(%Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset) do
    change(changeset, %{ password: Comeonin.Argon2.hashpwsalt(password) })
  end
  defp put_pass_hash(changeset), do: changeset
end
