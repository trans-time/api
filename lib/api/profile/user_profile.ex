defmodule Api.Profile.UserProfile do
  use Ecto.Schema
  import Ecto.Changeset
  alias Api.Profile.{UserProfile, UserTagSummary}
  alias Api.Accounts.User


  schema "user_profiles" do
    field :description, :string
    field :post_count, :integer, default: 0
    field :website, :string

    belongs_to :user, User
    has_one :user_tag_summary, UserTagSummary

    timestamps()
  end

  @doc false
  def changeset(%UserProfile{} = user_profile, attrs) do
    user_profile
    |> cast(attrs, [:description, :post_count, :website])
    |> validate_required([:post_count])
    |> unique_constraint(:user_id)
    |> assoc_constraint(:user)
  end
end
