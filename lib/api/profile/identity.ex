defmodule Api.Profile.Identity do
  use Ecto.Schema
  import Ecto.Changeset
  alias Api.Profile.{Identity, UserIdentity}


  schema "identities" do
    field :name, :string

    has_many :user_identities, UserIdentity

    timestamps()
  end

  @doc false
  def changeset(%Identity{} = identity, attrs) do
    identity
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> unique_constraint(:name)
  end
end
