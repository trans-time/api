defmodule ApiWeb.UserTagSummaryView do
  use ApiWeb, :view
  use JaSerializer.PhoenixView
  alias ApiWeb.{TagView, UserBareView}

  attributes [:summary]

  has_many :tags,
    serializer: TagView

  has_many :users,
    serializer: UserBareView
end
