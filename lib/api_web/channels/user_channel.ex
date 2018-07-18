defmodule ApiWeb.UserChannel do
  use Phoenix.Channel

  def join("user:" <> user_id, params, socket) do
    case Guardian.Phoenix.Socket.current_resource(socket).id do
      user_id -> {:ok, socket}
      _ -> :error
    end
  end
end
