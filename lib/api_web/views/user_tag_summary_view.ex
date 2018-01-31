defmodule ApiWeb.UserTagSummaryView do
  use JSONAPI.View, type: "user_tag_summaries"
  alias ApiWeb.{TagView, UserView}

  def fields do
    [:summary]
  end

  def relationships do
    [relationships: UserView, tags: TagView]
  end
end
