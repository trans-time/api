defmodule Api.Mail.Email do
  use Bamboo.Phoenix, view: ApiWeb.EmailView

  def welcome(username, email) do
    new_email
    |> from({"trans time", "hi@transtime.is"})
    |> to({username, email})
    |> assign(:username, username)
    |> put_html_layout({ApiWeb.LayoutView, "email.html"})
    |> put_text_layout(false)
    |> subject("welcome to trans time ◠‿◠")
    |> render("welcome.html")
    |> premail()
  end

  defp premail(email) do
    html = Premailex.to_inline_css(email.html_body)
    text = Premailex.to_text(email.html_body)

    email
    |> html_body(html)
    |> text_body(text)
  end
end
