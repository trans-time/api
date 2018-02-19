defmodule ApiWeb.SearchQueryView do
  use ApiWeb, :view
  use JaSerializer.PhoenixView
  alias ApiWeb.{IdentityView, TagView, UserView}

  def id(_post,_conn), do: 0

  has_many :identities,
    serializer: IdentityView,
    include: false

  has_many :tags,
    serializer: TagView,
    include: false

  has_many :users,
    serializer: UserView,
    include: false

  def preload(record_or_records, _conn, include_opts) do
    Api.Repo.preload(record_or_records, include_opts)
  end
end
