defmodule Api.Profile.Identity do
  use Api.Schema
  import Ecto.Changeset
  alias Api.Profile.{Identity, UserIdentity}


  schema "identities" do
    field :name, :string
    field :user_identity_count, :integer, default: 0

    has_many :user_identities, UserIdentity

    timestamps()
  end

  @doc false
  def changeset(%Identity{} = identity, attrs) do
    identity
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> validate_length(:name, max: 64, message: "remote.errors.detail.length.length")
    |> validate_format(:name, ~r/^[a-zA-Z0-9_]*$/, message: "remote.errors.detail.format.alphanumericUnderscore")
    |> unique_constraint(:name)
  end
end
