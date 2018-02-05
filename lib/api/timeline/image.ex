defmodule Api.Timeline.Image do
  use Ecto.Schema
  import Ecto.Changeset
  alias Api.Timeline.{Image, Post}


  schema "images" do
    field :filename, :string
    field :filesize, :integer
    field :order, :integer
    field :src, :string
    belongs_to :post, Post

    timestamps()
  end

  @doc false
  def changeset(%Image{} = panel, attrs) do
    panel
    |> cast(attrs, [:filename, :filesize, :order, :src])
    |> validate_required([:filename, :filesize, :order, :src])
  end
end
