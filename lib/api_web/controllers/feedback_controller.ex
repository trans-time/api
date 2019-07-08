import Ecto.Query

defmodule ApiWeb.FeedbackController do
  use ApiWeb, :controller
  use JaResource # Optionally put in web/web.ex
  plug JaResource
  alias Api.Accounts.User

  def model, do: User

  def handle_create(conn, attributes) do
    Api.Mail.Email.feedback(attributes)
    |> Api.Mail.Mailer.deliver_later()

    %{id: 0}
  end
end
