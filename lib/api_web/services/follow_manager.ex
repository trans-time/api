import Ecto.Query

defmodule ApiWeb.Services.FollowManager do
  alias Api.Relationship.Follow
  alias ApiWeb.Services.Notifications.{NotificationFollowManager,NotificationPrivateGrantManager,NotificationPrivateRequestManager}
  alias Ecto.Multi

  def delete(record) do
    Multi.new
    |> Multi.append(NotificationFollowManager.delete(record))
    |> Multi.delete(:follow, record)
  end

  def insert(attributes) do
    Multi.new
    |> Multi.insert(:follow, Follow.public_insert_follower_changeset(%Follow{}, attributes))
    |> Multi.merge(fn %{follow: follow} ->
      NotificationFollowManager.insert(follow)
    end)
  end

  def update(true = is_follower, record, attributes) do
    Multi.new
    |> Multi.update(:follow, Follow.public_update_follower_changeset(record, attributes))
    |> Multi.merge(fn %{follow: follow} ->
      NotificationPrivateRequestManager.insert(follow)
    end)
  end

  def update(false = is_follower, record, attributes) do
    Multi.new
    |> Multi.update(:follow, Follow.public_update_followed_changeset(record, attributes))
    |> Multi.merge(fn %{follow: follow} ->
      NotificationPrivateGrantManager.insert_or_delete(follow)
    end)
  end
end
