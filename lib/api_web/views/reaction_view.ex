defmodule ApiWeb.ReactionView do
  use ApiWeb, :view
  use JaSerializer.PhoenixView
  alias ApiWeb.{UserView}

  def type(_post,_conn), do: "reaction"

  attributes [:type]

  has_one :user,
    serializer: UserView,
    include: false

  def preload(record_or_records, _conn, include_opts) do
    Api.Repo.preload(record_or_records, include_opts)
  end
end
