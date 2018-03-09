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
    |> validate_length(:description, max: 1000, message: "remote.errors.detail.length.length")
    |> validate_length(:website, max: 100, message: "remote.errors.detail.length.length")
    |> validate_format(:website, ~r/^(http:\/\/www\.|https:\/\/www\.|http:\/\/|https:\/\/)?[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?$/, message: "remote.errors.detail.format.url")
    |> unique_constraint(:user_id)
    |> assoc_constraint(:user)
  end
end
