defmodule Api.Timeline.ContentWarning do
  use Api.Schema
  import Ecto.Changeset
  alias Api.Timeline.{ContentWarning, TimelineItem}


  schema "content_warnings" do
    field :name, :string
    field :tagging_count, :integer, default: 0
    many_to_many :timeline_items, TimelineItem, join_through: "timeline_items_content_warnings"

    timestamps()
  end

  @doc false
  def changeset(%ContentWarning{} = content_warning, attrs) do
    content_warning
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> unique_constraint(:name)
    |> validate_length(:name, max: 64, message: "remote.errors.detail.length.length")
  end
end
