import Ecto.Query

defmodule ApiWeb.CurrentUserView do
  use ApiWeb, :view
  use JaSerializer.PhoenixView

  attributes [:language, :unseen_notification_count]

  def unseen_notification_count(current_user) do
    Enum.at(Api.Repo.all(from(
      n in Api.Notifications.Notification,
      where: n.user_id == ^current_user.user_id and n.is_seen == ^false,
      select: count(n.id)
    )), 0)
  end
end
