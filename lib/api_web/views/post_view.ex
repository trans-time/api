defmodule ApiWeb.PostView do
  use ApiWeb, :view
  use JaSerializer.PhoenixView
  alias ApiWeb.{ImageView, ReactionView, TimelineItemView}

  attributes [:nsfw, :text, :comment_count, :moon_count, :star_count, :sun_count]

  has_one :timeline_item,
    serializer: TimelineItemView,
    include: false

  has_many :images,
    serializer: ImageView

  has_many :reactions,
    serializer: ReactionView

  def timeline_item(%{timeline_item: %Ecto.Association.NotLoaded{}, timeline_item_id: nil}, _conn), do: nil
  def timeline_item(%{timeline_item: %Ecto.Association.NotLoaded{}, timeline_item_id: id}, _conn), do: %{id: id}
  def timeline_item(%{timeline_item: timeline_item}, _conn), do: timeline_item

  def preload(record_or_records, _conn, include_opts) do
    Api.Repo.preload(record_or_records, include_opts)
  end
end
