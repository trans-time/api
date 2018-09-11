import Ecto.Query

defmodule ApiWeb.FeedbackController do
  use ApiWeb, :controller
  use JaResource # Optionally put in web/web.ex
  plug JaResource
  alias Api.Accounts.User

  def model, do: User

  def handle_create(conn, attributes) do
    case Recaptcha.verify(attributes["re_captcha_response"]) do
      {:ok, response} ->
        Api.Mail.Email.feedback(attributes)
        |> Api.Mail.Mailer.deliver_later()

        %{id: 0}
      {:error, errors} -> invalid_recaptcha(conn)
    end
  end

  defp invalid_recaptcha(conn) do
    conn
    |> put_status(401)
    |> json(%{errors: [%{title: "remote.errors.title.invalid", detail: "remote.errors.detail.invalid.recaptcha", status: "401"}]})
  end
end
