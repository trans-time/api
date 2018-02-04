defmodule Api.Relationship.Follow do
  use Ecto.Schema
  import Ecto.Changeset
  alias Api.Accounts.User
  alias Api.Relationship.Follow


  schema "follows" do
    field :can_view_private, :boolean, default: false
    field :requested_private, :boolean, default: false

    belongs_to :followed, User
    belongs_to :follower, User

    timestamps()
  end

  @doc false
  def changeset(%Follow{} = follow, attrs) do
    follow
    |> cast(attrs, [:can_view_private, :requested_private])
    |> validate_required([:can_view_private, :requested_private])
  end
end
