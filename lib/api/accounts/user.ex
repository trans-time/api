defmodule Api.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias Api.Accounts.User
  alias Api.Profile.{UserIdentity, UserProfile, UserTagSummary}


  schema "users" do
    field :avatar, :string
    field :display_name, :string
    field :is_moderator, :boolean, default: false
    field :pronouns, :string
    field :username, :string

    has_many :user_identities, UserIdentity
    has_one :user_profile, UserProfile
    many_to_many :user_tag_summaries, UserTagSummary, join_through: "user_tag_summaries_relationships"

    timestamps()
  end

  @doc false
  def changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, [:avatar, :display_name, :is_moderator, :pronouns, :username])
    |> validate_required([:avatar, :display_name, :is_moderator, :pronouns, :username])
    |> unique_constraint(:username)
  end
end
