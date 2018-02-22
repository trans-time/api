defmodule ApiWeb.BlockView do
  use ApiWeb, :view
  use JaSerializer.PhoenixView
  alias ApiWeb.{UserView}

  attributes [:can_view_private, :requested_private]

  has_one :blocked,
    serializer: UserView,
    include: false

  has_one :blocker,
    serializer: UserView,
    include: false

  def blocked(%{blocked: %Ecto.Association.NotLoaded{}, blocked_id: nil}, _conn), do: nil
  def blocked(%{blocked: %Ecto.Association.NotLoaded{}, blocked_id: id}, _conn), do: %{id: id}
  def blocked(%{blocked: blocked}, _conn), do: blocked

  def blocker(%{blocker: %Ecto.Association.NotLoaded{}, blocker_id: nil}, _conn), do: nil
  def blocker(%{blocker: %Ecto.Association.NotLoaded{}, blocker_id: id}, _conn), do: %{id: id}
  def blocker(%{blocker: blocker}, _conn), do: blocker

  def preload(record_or_records, _conn, include_opts) do
    Api.Repo.preload(record_or_records, include_opts)
  end
end
