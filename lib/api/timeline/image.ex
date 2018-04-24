defmodule Api.Timeline.Image do
  use Api.Schema
  use Arc.Ecto.Schema
  import Ecto.Changeset
  alias Api.Timeline.{Image, Post}


  schema "images" do
    field :order, :integer
    field :src, Api.Timeline.ImageFile.Type
    belongs_to :post, Post

    timestamps()
  end

  @doc false
  def changeset(%Image{} = panel, attrs) do
    panel
    |> cast(attrs, [:order, :post_id])
    |> cast_attachments(attrs, [:src])
    |> validate_required([:order])
  end
end
