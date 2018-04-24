defmodule ApiWeb.TimelineItemView do
  use ApiWeb, :view
  use JaSerializer.PhoenixView
  alias ApiWeb.{PostView, TagView, UserView}

  attributes [:date, :deleted, :private]

  has_one :user,
    serializer: UserView,
    include: false

  has_many :tags,
    serializer: TagView

  has_many :users,
    serializer: UserView

  has_one :post,
    serializer: PostView

  def current_user_reaction(_params, _conn), do: nil

  def post(%{post: %Ecto.Association.NotLoaded{}, post_id: nil}, _conn), do: nil
  def post(%{post: %Ecto.Association.NotLoaded{}, post_id: id}, _conn), do: %{id: id}
  def post(%{post: post}, _conn), do: post

  def preload(record_or_records, _conn, include_opts) do
    Api.Repo.preload(record_or_records, include_opts)
  end
end
