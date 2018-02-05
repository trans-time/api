defmodule ApiWeb.FollowView do
  use ApiWeb, :view
  use JaSerializer.PhoenixView
  alias ApiWeb.{UserView}

  attributes [:can_view_private, :requested_private]

  has_one :followed,
    serializer: UserView,
    include: false

  has_one :follower,
    serializer: UserView,
    include: false

  def followed(%{followed: %Ecto.Association.NotLoaded{}, followed_id: nil}, _conn), do: nil
  def followed(%{followed: %Ecto.Association.NotLoaded{}, followed_id: id}, _conn), do: %{id: id}
  def followed(%{followed: followed}, _conn), do: followed

  def follower(%{follower: %Ecto.Association.NotLoaded{}, follower_id: nil}, _conn), do: nil
  def follower(%{follower: %Ecto.Association.NotLoaded{}, follower_id: id}, _conn), do: %{id: id}
  def follower(%{follower: follower}, _conn), do: follower

  def preload(record_or_records, _conn, include_opts) do
    Api.Repo.preload(record_or_records, include_opts)
  end
end
