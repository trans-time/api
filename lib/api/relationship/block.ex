defmodule Api.Relationship.Block do
  use Ecto.Schema
  import Ecto.Changeset
  alias Api.Accounts.User
  alias Api.Relationship.Block


  schema "blocks" do
    belongs_to :blocked, User
    belongs_to :blocker, User

    timestamps()
  end

  @doc false
  def changeset(%Block{} = block, attrs) do
    block
    |> cast(attrs, [:blocker_id, :blocked_id])
    |> assoc_constraint(:blocked)
    |> assoc_constraint(:blocker)
  end
end
