defmodule Api.Notifications.NotificationPrivateGrant do
  use Api.Schema
  import Ecto.Changeset
  alias Api.Relationship.Follow
  alias Api.Notifications.{NotificationPrivateGrant, Notification}


  schema "notification_private_grants" do
    belongs_to :follow, Follow
    belongs_to :notification, Notification
  end

  @doc false
  def private_changeset(%NotificationPrivateGrant{} = notification_private_grant, attrs) do
    notification_private_grant
    |> cast(attrs, [:follow_id, :notification_id])
    |> validate_required([:follow_id, :notification_id])
    |> assoc_constraint(:follow)
    |> assoc_constraint(:notification)
  end
end
