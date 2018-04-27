defmodule Api.Profile.UserTagSummary do
  use Api.Schema
  import Ecto.Changeset
  alias Api.Accounts.User
  alias Api.Profile.{UserTagSummary, UserTagSummaryTag, UserTagSummaryUser}


  schema "user_tag_summaries" do
    field :private_timeline_item_ids, {:array, :integer}, default: []

    has_many :user_tag_summary_tags, UserTagSummaryTag
    has_many :user_tag_summary_users, UserTagSummaryUser
    belongs_to :author, User
    belongs_to :subject, User

    timestamps()
  end

  @doc false
  def changeset(%UserTagSummary{} = user_tag_summary, attrs) do
    user_tag_summary
    |> cast(attrs, [:author_id, :subject_id])
    |> assoc_constraint(:author)
    |> assoc_constraint(:subject)
  end
end
