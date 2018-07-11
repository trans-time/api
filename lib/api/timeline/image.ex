defmodule Api.Timeline.Image do
  use Api.Schema
  use Arc.Ecto.Schema
  import Ecto.Changeset
  alias Api.Timeline.{Image, Post}

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "images" do
    field :order, :integer
    field :src, Api.Timeline.ImageFile.Type
    field :is_marked_for_deletion, :boolean, default: false
    field :is_marked_for_deletion_by_moderator, :boolean, default: false
    field :is_marked_for_deletion_by_user, :boolean, default: false
    field :marked_for_deletion_on, :utc_datetime
    belongs_to :post, Post

    timestamps()
  end

  @doc false
  def changeset(%Image{} = image, attrs) do
    image
    |> cast(attrs, [:order, :post_id, :is_marked_for_deletion])
    |> cast_attachments(attrs, [:src])
    |> validate_required([:order, :is_marked_for_deletion, :is_marked_for_deletion_by_moderator, :is_marked_for_deletion_by_user])
  end

  @doc false
  def private_changeset(%Image{} = image, attrs) do
    image
    |> cast(attrs, [:is_marked_for_deletion, :is_marked_for_deletion_by_moderator, :is_marked_for_deletion_by_user, :marked_for_deletion_on])
    |> validate_required([:order, :is_marked_for_deletion, :is_marked_for_deletion_by_moderator, :is_marked_for_deletion_by_user])
  end
end
