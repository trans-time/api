import Ecto.Query

defmodule Api.Accounts.CurrentUser do
  use Api.Schema
  import Ecto.Changeset
  alias Api.Accounts.{CurrentUser, User}


  schema "current_users" do
    field :language, :string, default: "en-us"

    belongs_to :user, User

    timestamps()
  end

  @doc false
  def changeset(%CurrentUser{} = user, attrs) do
    user
    |> cast(attrs, [:language])
    |> validate_required([:language])
    |> unique_constraint(:user_id)
    |> assoc_constraint(:user)
  end
end
