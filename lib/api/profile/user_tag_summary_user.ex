defmodule Api.Profile.UserTagSummaryUser do
  use Api.Schema
  import Ecto.Changeset
  alias Api.Accounts.User
  alias Api.Profile.{UserTagSummary, UserTagSummaryUser}


  schema "user_tag_summary_users" do
    field :timeline_item_ids, {:array, :integer}, default: []

    belongs_to :user_tag_summary, UserTagSummary
    belongs_to :user, User

    timestamps()
  end

  @doc false
  def changeset(%UserTagSummaryUser{} = user_tag_summary_user, attrs) do
    user_tag_summary_user
    |> cast(attrs, [:timeline_item_ids, :user_tag_summary_id, :user_id])
  end
end
