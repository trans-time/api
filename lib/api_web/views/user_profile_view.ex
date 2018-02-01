defmodule ApiWeb.UserProfileView do
  use ApiWeb, :view
  use JaSerializer.PhoenixView
  alias ApiWeb.{UserTagSummaryView, UserView}

  attributes [:description, :total_posts, :website]

  has_one :user_tag_summary,
    serializer: UserTagSummaryView
end
