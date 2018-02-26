import Ecto.Query

defmodule Api.Accounts.CurrentUser do
  use Ecto.Schema
  import Ecto.Changeset
  alias Api.Accounts.{CurrentUser, User}


  schema "current_users" do
    field :language, :string, default: "en-us"
    field :unread_notification_count, :integer, default: 0

    belongs_to :user, User

    timestamps()
  end

  @doc false
  def changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, [:language, :unread_notification_count])
    |> validate_required([:language, :unread_notification_count])
  end
end
