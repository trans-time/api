defmodule ApiWeb.UserIdentityView do
  use ApiWeb, :view
  use JaSerializer.PhoenixView
  alias ApiWeb.{IdentityView, UserView}

  attributes [:end_date, :start_date]

  has_one :identity,
    serializer: IdentityView,
    include: true

  has_one :user,
    serializer: UserView

  def user(%{user: %Ecto.Association.NotLoaded{}, user_id: nil}, _conn), do: nil
  def user(%{user: %Ecto.Association.NotLoaded{}, user_id: id}, _conn), do: %{id: id}
  def user(%{user: user}, _conn), do: user

  def preload(record_or_records, _conn, include_opts) do
    Api.Repo.preload(record_or_records, :identity)
  end
end
