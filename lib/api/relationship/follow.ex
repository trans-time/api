defmodule Api.Relationship.Follow do
  use Api.Schema
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
  def public_insert_follower_changeset(%Follow{} = follow, attrs) do
    follow
    |> cast(attrs, [:follower_id, :followed_id])
    |> validate_required([:can_view_private, :requested_private])
    |> unique_constraint(:followed_id, name: :follows_followed_id_follower_id_index, message: "remote.errors.detail.unique.follow")
    |> assoc_constraint(:followed)
    |> assoc_constraint(:follower)
  end

  @doc false
  def public_update_follower_changeset(%Follow{} = follow, attrs) do
    follow
    |> cast(attrs, [:requested_private])
    |> validate_required([:requested_private])
  end

  @doc false
  def public_update_followed_changeset(%Follow{} = follow, attrs) do
    follow
    |> cast(attrs, [:can_view_private])
    |> validate_required([:can_view_private])
  end
end
