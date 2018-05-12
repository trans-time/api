defmodule Api.Notifications.Notification do
  use Api.Schema
  import Ecto.Changeset
  alias Api.Accounts.User
  alias Api.Notifications.Notification


  schema "notifications" do
    field :read, :boolean, default: false
    field :seen, :boolean, default: false

    belongs_to :user, User

    timestamps()
  end

  @doc false
  def changeset(%Notification{} = notification, attrs) do
    notification
    |> cast(attrs, [:read, :seen])
    |> validate_required([:read, :seen])
  end
end
