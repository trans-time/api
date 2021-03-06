import Ecto.Query

defmodule Api.Moderation.TextVersion do
  use Api.Schema
  import Ecto.Changeset
  alias Api.Moderation.TextVersion
  alias Api.Timeline.{Comment, Post}


  schema "text_versions" do
    field :text, :string
    field :attribute, :string

    belongs_to :comment, Comment
    belongs_to :post, Post

    timestamps()
  end

  @doc false
  def changeset(%TextVersion{} = user, attrs) do
    user
    |> cast(attrs, [:text, :attribute, :comment_id, :post_id])
    |> validate_required([:text, :attribute])
    |> assoc_constraint(:comment)
    |> assoc_constraint(:post)
  end
end
