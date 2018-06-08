defmodule Api.Notifications.NotificationFollow do
  use Api.Schema
  import Ecto.Changeset
  alias Api.Relationship.Follow
  alias Api.Notifications.{NotificationFollow, Notification}


  schema "notification_follows" do
    belongs_to :follow, Follow
    belongs_to :notification, Notification
  end

  @doc false
  def private_changeset(%NotificationFollow{} = notification_follow, attrs) do
    notification_follow
    |> cast(attrs, [:follow_id, :notification_id])
    |> validate_required([:follow_id, :notification_id])
    |> assoc_constraint(:follow)
    |> assoc_constraint(:notification)
  end
end
