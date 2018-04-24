defmodule Api.Search.SearchQuery do
  use Api.Schema
  import Ecto.Changeset
  alias Api.Search.SearchQuery
  alias Api.Account.User
  alias Api.Profile.Identiity
  alias Api.Timeline.Tag


  schema "search_queries" do
    field :query, :string

    has_many :identities, Identity
    has_many :tags, Tag
    has_many :users, User

    timestamps()
  end

  @doc false
  def changeset(%SearchQuery{} = search_query, attrs) do
    search_query
    |> cast(attrs, [:query])
    |> validate_required([])
  end
end
