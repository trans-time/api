defmodule ApiWeb.CurrentUserView do
  use ApiWeb, :view
  use JaSerializer.PhoenixView

  attributes [:language, :unread_notification_count]
end
