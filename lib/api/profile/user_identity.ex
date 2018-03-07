defmodule Api.Profile.UserIdentity do
  use Ecto.Schema
  import Ecto.Changeset
  alias Api.Accounts.User
  alias Api.Profile.{Identity, UserIdentity}


  schema "user_identities" do
    field :end_date, :utc_datetime
    field :start_date, :utc_datetime
    belongs_to :identity, Identity
    belongs_to :user, User

    timestamps()
  end

  @doc false
  def changeset(%UserIdentity{} = user_identity, attrs) do
    user_identity
    |> cast(attrs, [:end_date, :identity_id, :start_date, :user_id])
    |> assoc_constraint(:identity)
    |> assoc_constraint(:user)
  end
end
