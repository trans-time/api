defmodule ApiWeb.ReactionView do
  use ApiWeb, :view
  use JaSerializer.PhoenixView
  alias ApiWeb.{UserView}

  attributes [:reaction_type]

  has_one :user,
    serializer: UserView,
    include: false

  def user(%{user: %Ecto.Association.NotLoaded{}, user_id: nil}, _conn), do: nil
  def user(%{user: %Ecto.Association.NotLoaded{}, user_id: id}, _conn), do: %{id: id}
  def user(%{user: user}, _conn), do: user

  def preload(record_or_records, _conn, include_opts) do
    Api.Repo.preload(record_or_records, include_opts)
  end
end
