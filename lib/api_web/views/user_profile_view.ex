defmodule ApiWeb.UserProfileView do
  use JSONAPI.View, type: "user_profiles"
  alias ApiWeb.{UserTagSummaryView}

  def fields do
    [:description, :total_posts, :website]
  end

  def relationships do
    [userTagSummary: UserTagSummaryView]
  end
end
