defmodule ApiWeb.TimelineItemView do
  use ApiWeb, :view
  use JaSerializer.PhoenixView
  alias ApiWeb.{PostView, TagView, UserView}

  attributes [:comments_locked, :date, :deleted, :private, :total_comments]

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

  def preload(record_or_records, _conn, include_opts) do
    Api.Repo.preload(record_or_records, include_opts)
  end
end
