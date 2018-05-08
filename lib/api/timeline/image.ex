defmodule Api.Timeline.Image do
  use Api.Schema
  use Arc.Ecto.Schema
  import Ecto.Changeset
  alias Api.Timeline.{Image, Post}


  schema "images" do
    field :order, :integer
    field :src, Api.Timeline.ImageFile.Type
    field :deleted, :boolean, default: false
    field :deleted_by_moderator, :boolean, default: false
    field :deleted_by_user, :boolean, default: false
    field :deleted_at, :utc_datetime
    belongs_to :post, Post

    timestamps()
  end

  @doc false
  def changeset(%Image{} = image, attrs) do
    image
    |> cast(attrs, [:order, :post_id])
    |> cast_attachments(attrs, [:src])
    |> validate_required([:order, :deleted, :deleted_by_moderator, :deleted_by_user])
  end

  @doc false
  def private_changeset(%Image{} = image, attrs) do
    image
    |> cast(attrs, [:deleted, :deleted_by_moderator, :deleted_by_user, :deleted_at])
    |> validate_required([:order, :deleted, :deleted_by_moderator, :deleted_by_user])
  end
end
