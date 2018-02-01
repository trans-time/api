defmodule ApiWeb.UserTagSummaryView do
  use ApiWeb, :view
  use JaSerializer.PhoenixView
  alias ApiWeb.{TagView, UserView}

  attributes [:summary]

  # has_many :relationships,
  #   serializer: UserView

  has_many :tags,
    serializer: TagView
end
