defmodule Api.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias Api.Accounts.User


  schema "users" do
    field :avatar, :string
    field :display_name, :string
    field :is_moderator, :boolean, default: false
    field :pronouns, :string
    field :username, :string

    timestamps()
  end

  @doc false
  def changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, [:avatar, :display_name, :is_moderator, :pronouns, :username])
    |> validate_required([:avatar, :display_name, :is_moderator, :pronouns, :username])
    |> unique_constraint(:username)
  end
end
