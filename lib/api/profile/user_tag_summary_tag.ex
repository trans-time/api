defmodule Api.Profile.UserTagSummaryTag do
  use Api.Schema
  import Ecto.Changeset
  alias Api.Profile.{UserTagSummary, UserTagSummaryTag}
  alias Api.Timeline.Tag


  schema "user_tag_summary_tags" do
    field :timeline_item_ids, {:array, :integer}, default: []

    belongs_to :user_tag_summary, UserTagSummary
    belongs_to :tag, Tag

    timestamps()
  end

  @doc false
  def changeset(%UserTagSummaryTag{} = user_tag_summary_tag, attrs) do
    user_tag_summary_tag
    |> cast(attrs, [:timeline_item_ids, :user_tag_summary_id, :tag_id])
  end
end
