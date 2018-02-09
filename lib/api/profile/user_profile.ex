defmodule Api.Profile.UserProfile do
  use Ecto.Schema
  import Ecto.Changeset
  alias Api.Profile.{UserProfile, UserTagSummary}
  alias Api.Accounts.User


  schema "user_profiles" do
    field :description, :string
    field :total_posts, :integer, default: 0
    field :website, :string

    belongs_to :user, User
    has_one :user_tag_summary, UserTagSummary

    timestamps()
  end

  @doc false
  def changeset(%UserProfile{} = user_profile, attrs) do
    user_profile
    |> cast(attrs, [:description, :total_posts, :website])
    |> validate_required([:description, :total_posts, :website])
  end
end
