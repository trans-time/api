import Ecto.Query

defmodule Api.Accounts.User do
  use Api.Schema
  use Arc.Ecto.Schema
  import Ecto.Changeset
  alias Api.Accounts.{CurrentUser, User, UserPassword}
  alias Api.Moderation.{Flag, ModerationReport}
  alias Api.Profile.{UserIdentity, UserProfile, UserTagSummary}
  alias Api.Relationship.{Block, Follow}
  alias Api.Timeline.{Reaction, TimelineItem}
  alias Api.Mail.Subscription


  schema "users" do
    field :avatar, Api.Profile.Avatar.Type
    field :email, :string
    field :follower_count, :integer, default: 0
    field :display_name, :string
    field :email_is_confirmed, :boolean, default: false
    field :is_banned, :boolean, default: false
    field :is_moderator, :boolean, default: false
    field :is_trans, :boolean, default: true
    field :pronouns, :string
    field :username, :string

    has_many :blockeds, Block, foreign_key: :blocker_id
    has_many :blockers, Block, foreign_key: :blocked_id
    has_one :current_user, CurrentUser
    has_one :user_password, UserPassword
    has_many :indictions, ModerationReport, foreign_key: :indicted_id
    has_many :flags, Flag
    has_many :followeds, Follow, foreign_key: :follower_id
    has_many :followers, Follow, foreign_key: :followed_id
    has_many :reactions, Reaction
    has_many :timeline_items, TimelineItem
    has_many :user_identities, UserIdentity
    has_one :user_profile, UserProfile
    has_many :user_tag_summaries_about_user, UserTagSummary, foreign_key: :subject_id
    has_many :user_tag_summaries_by_user, UserTagSummary, foreign_key: :author_id
    has_many :subscriptions, Subscription

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
    user = Api.Repo.preload(user, :user_password)
    Comeonin.Argon2.checkpw(password, user.user_password.password)
  end

  @doc false
  def public_insert_changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, [:username])
    |> validate_required([:username])
    |> validate_length(:username, max: 64, message: "remote.errors.detail.length.length")
    |> validate_format(:username, ~r/^[a-zA-Z0-9_]*$/, message: "remote.errors.detail.format.alphanumericUnderscore")
    |> unique_constraint(:username)
    |> public_shared_changeset(attrs)
  end

  @doc false
  def public_update_changeset(%User{} = user, attrs) do
    user
    |> public_shared_changeset(attrs)
  end

  @doc false
  defp public_shared_changeset(user, attrs) do
    user
    |> cast(attrs, [:display_name, :email, :pronouns, :is_trans])
    |> cast_attachments(attrs, [:avatar])
    |> validate_required([:email])
    |> validate_length(:display_name, max: 100, message: "remote.errors.detail.length.length")
    |> validate_length(:email, max: 1000, message: "remote.errors.detail.length.length")
    |> validate_format(:email, ~r/^[A-Za-z0-9._%+-+']+@[A-Za-z0-9.-]+\.[A-Za-z]+$/, message: "remote.errors.detail.format.email")
    |> validate_length(:pronouns, max: 64, message: "remote.errors.detail.length.length")
    |> unique_constraint(:email)
  end

  @doc false
  def private_changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, [:is_banned, :email_is_confirmed])
    |> public_shared_changeset(attrs)
  end
end
