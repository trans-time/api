defmodule Api.Profile.UserTagSummary do
  use Ecto.Schema
  import Ecto.Changeset
  alias Api.Accounts.User
  alias Api.Profile.{UserProfile, UserTagSummary}
  alias Api.Timeline.Tag


  schema "user_tag_summaries" do
    field :summary, :map
    many_to_many :users, User, join_through: "user_tag_summaries_users"
    many_to_many :tags, Tag, join_through: "user_tag_summaries_tags"
    belongs_to :user_profile, UserProfile

    timestamps()
  end

  @doc false
  def changeset(%UserTagSummary{} = user_tag_summary, attrs) do
    user_tag_summary
    |> cast(attrs, [:summary])
    |> validate_required([:summary])
    |> unique_constraint(:user_profile_id)
    |> assoc_constraint(:user_profile)
  end
end
