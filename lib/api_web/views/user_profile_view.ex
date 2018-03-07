defmodule ApiWeb.UserProfileView do
  use ApiWeb, :view
  use JaSerializer.PhoenixView
  alias ApiWeb.{UserTagSummaryView, UserView}

  attributes [:description, :post_count, :website]

  has_one :user_tag_summary,
    serializer: UserTagSummaryView

  def user_tag_summary(%{user_tag_summary: %Ecto.Association.NotLoaded{}, user_tag_summary_id: nil}, _conn), do: nil
  def user_tag_summary(%{user_tag_summary: %Ecto.Association.NotLoaded{}, user_tag_summary_id: id}, _conn), do: %{id: id}
  def user_tag_summary(%{user_tag_summary: user_tag_summary}, _conn), do: user_tag_summary
end
