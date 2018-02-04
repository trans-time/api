defmodule ApiWeb.TimelineItemView do
  use ApiWeb, :view
  use JaSerializer.PhoenixView
  alias ApiWeb.{TagView, UserView}

  attributes [:comments_locked, :date, :deleted, :private, :total_comments]

  has_one :user,
    serializer: UserView,
    include: false

  has_many :tags,
    serializer: TagView

  has_many :users,
    serializer: UserView
end
