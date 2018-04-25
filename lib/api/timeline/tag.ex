defmodule Api.Timeline.Tag do
  use Api.Schema
  import Ecto.Changeset
  alias Api.Timeline.Tag
  alias Api.Profile.UserTagSummary


  schema "tags" do
    field :name, :string
    many_to_many :user_tag_summaries, UserTagSummary, join_through: "user_tag_summaries_tags"

    timestamps()
  end

  @doc false
  def changeset(%Tag{} = tag, attrs) do
    tag
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> unique_constraint(:name)
    |> validate_format(:name, ~r/^[a-zA-Z0-9_]*$/, message: "remote.errors.detail.format.alphanumericUnderscore")
  end
end
