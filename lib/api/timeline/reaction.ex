defmodule Api.Timeline.Reaction do
  use Ecto.Schema
  import Ecto.Changeset
  alias Api.Accounts.User
  alias Api.Timeline.{Comment, Post, Reaction, TimelineItem}


  schema "reactions" do
    field :type, :integer

    belongs_to :comment, Comment
    belongs_to :post, Post
    belongs_to :user, User

    timestamps()
  end

  @doc false
  def changeset(%Reaction{} = reaction, attrs) do
    reaction
    |> cast(attrs, [:type])
    |> validate_required([:type])
    |> prepare_changes(fn (changeset) ->
      inc = case changeset.data.type do
        1 -> [star_count: 1]
        2 -> [sun_count: 1]
        3 -> [moon_count: 1]
      end

      polymorph = cond do
        get_change(changeset, :post_id) -> :post
        get_change(changeset, :comment_id) -> :comment
      end

      Ecto.assoc(changeset.data, polymorph)
      |> Repo.update_all(inc: inc)
      
      changeset
    end)
  end
end
