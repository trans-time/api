defmodule Api.Timeline.Reaction do
  use Ecto.Schema
  import Ecto.Changeset
  alias Api.Accounts.User
  alias Api.Timeline.{Reaction, TimelineItem}


  schema "reactions" do
    field :type, :integer

    belongs_to :timeline_item, TimelineItem
    belongs_to :user, User

    timestamps()
  end

  @doc false
  def changeset(%Reaction{} = reaction, attrs) do
    reaction
    |> cast(attrs, [:type])
    |> validate_required([:type])
  end
end
