defmodule Api.Timeline.Reaction do
  use Api.Schema
  import Ecto.Changeset
  alias Api.Accounts.User
  alias Api.Timeline.{Comment, Reaction, TimelineItem}


  schema "reactions" do
    field :reaction_type, :integer

    belongs_to :comment, Comment
    belongs_to :timeline_item, TimelineItem
    belongs_to :user, User

    timestamps()
  end

  @doc false
  def changeset(%Reaction{} = reaction, attrs) do
    reaction
    |> cast(attrs, [:reaction_type, :comment_id, :timeline_item_id, :user_id])
    |> validate_required([:reaction_type])
    |> unique_constraint(:comment_id, name: :reactions_comment_id_user_id_index, message: "remote.errors.detail.unique.reaction")
    |> unique_constraint(:timeline_item_id, name: :reactions_timeline_item_id_user_id_index, message: "remote.errors.detail.unique.reaction")
    |> assoc_constraint(:comment)
    |> assoc_constraint(:timeline_item)
    |> assoc_constraint(:user)
  end
end
