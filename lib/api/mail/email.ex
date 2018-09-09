defmodule Api.Mail.Email do
  use Bamboo.Phoenix, view: ApiWeb.EmailView

  def welcome(user, mail_subscription_token, options) do
    new_email
    |> from({"trans time", "hi@transtime.is"})
    |> to({user.username, user.email})
    |> assign(:username, user.username)
    |> assign(:mail_confirmation_token, options.mail_confirmation_token.token)
    |> add_mail_subscription_token(mail_subscription_token)
    |> put_html_layout({ApiWeb.LayoutView, "email.html"})
    |> put_text_layout(false)
    |> subject("welcome to trans time ◠‿◠")
    |> render("welcome.html")
    |> premail()
  end

  def new_email_confirmation(user, mail_subscription_token, options) do
    new_email
    |> from({"trans time", "hi@transtime.is"})
    |> to({user.username, options.mail_confirmation_token.email || user.email})
    |> assign(:username, user.username)
    |> assign(:mail_confirmation_token, options.mail_confirmation_token.token)
    |> add_mail_subscription_token(mail_subscription_token)
    |> put_html_layout({ApiWeb.LayoutView, "email.html"})
    |> put_text_layout(false)
    |> subject("new email confirmation")
    |> render("new_email_confirmation.html")
    |> premail()
  end

  def confirmation_reminder(user, mail_subscription_token, options) do
    new_email
    |> from({"trans time", "hi@transtime.is"})
    |> to({user.username, options.mail_confirmation_token.email || user.email})
    |> assign(:username, user.username)
    |> assign(:mail_confirmation_token, options.mail_confirmation_token.token)
    |> add_mail_subscription_token(mail_subscription_token)
    |> put_html_layout({ApiWeb.LayoutView, "email.html"})
    |> put_text_layout(false)
    |> subject("please remember to confirm your email")
    |> render("confirmation_reminder.html")
    |> premail()
  end

  def password_reset(user, mail_subscription_token, options) do
    new_email
    |> from({"trans time", "hi@transtime.is"})
    |> to({user.username, user.email})
    |> assign(:username, user.username)
    |> assign(:mail_password_reset_token, options.mail_password_reset_token.token)
    |> add_mail_subscription_token(mail_subscription_token)
    |> put_html_layout({ApiWeb.LayoutView, "email.html"})
    |> put_text_layout(false)
    |> subject("password reset")
    |> render("password_reset.html")
    |> premail()
  end

  def mail_recovery(user, mail_subscription_token, options) do
    new_email
    |> from({"trans time", "hi@transtime.is"})
    |> to({user.username, user.mail_recovery_token.email})
    |> assign(:username, user.username)
    |> assign(:mail_recovery_token, options.mail_recovery_token.token)
    |> assign(:new_email_address, options.user.email)
    |> add_mail_subscription_token(mail_subscription_token)
    |> put_html_layout({ApiWeb.LayoutView, "email.html"})
    |> put_text_layout(false)
    |> subject("your email address has changed")
    |> render("mail_recovery.html")
    |> premail()
  end

  def account_locked(user, mail_subscription_token, options) do
    new_email
    |> from({"trans time", "hi@transtime.is"})
    |> to({user.username, user.email})
    # |> to({"my_username", "hi@transtime.is"})
    |> assign(:username, user.username)
    |> assign(:mail_unlock_token, options.mail_unlock_token.token)
    |> add_mail_subscription_token(mail_subscription_token)
    |> put_html_layout({ApiWeb.LayoutView, "email.html"})
    |> put_text_layout(false)
    |> subject("your account has been locked")
    |> render("account_locked.html")
    |> premail()
  end

  defp premail(email) do
    html = Premailex.to_inline_css(email.html_body)
    text = Premailex.to_text(email.html_body)

    email
    |> html_body(html)
    |> text_body(text)
  end

  defp add_mail_subscription_token(email, mail_subscription_token) do
    email
    |> assign(:mail_subscription_token, mail_subscription_token.token)
  end
end
