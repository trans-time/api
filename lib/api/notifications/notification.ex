defmodule Api.Notifications.Notification do
  use Api.Schema
  import Ecto.Changeset
  alias Api.Accounts.User
  alias Api.Notifications.{Notification, NotificationCommentAt, NotificationComment, NotificationTimelineItemAt}


  schema "notifications" do
    field :read, :boolean, default: false
    field :seen, :boolean, default: false

    belongs_to :user, User
    has_one :notification_comment_at, NotificationCommentAt
    has_one :notification_comment, NotificationComment
    has_one :notification_timeline_item_at, NotificationTimelineItemAt

    timestamps()
  end

  @doc false
  def public_update_changeset(%Notification{} = notification, attrs) do
    notification
    |> cast(attrs, [:read, :seen])
    |> validate_required([:read, :seen])
  end

  @doc false
  def private_changeset(%Notification{} = notification, attrs) do
    notification
    |> cast(attrs, [:user_id])
    |> validate_required([:user_id])
    |> assoc_constraint(:user)
  end
end
