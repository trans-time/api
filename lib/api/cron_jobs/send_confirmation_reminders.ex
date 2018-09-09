import Ecto.Query

defmodule Api.CronJobs.SendConfirmationReminder do
  alias Api.Mail.MailConfirmationToken
  alias ApiWeb.Services.MailManager
  alias ApiWeb.Services.Notifications.NotificationEmailConfirmationManager
  alias Ecto.Multi

  def call() do
    datetime = Timex.shift(Timex.now, days: -3)
    mail_confirmation_tokens = from(mct in MailConfirmationToken, where: mct.reminder_was_sent == ^false and mct.inserted_at <= ^datetime)
    |> Api.Repo.all
    |> Api.Repo.preload([:user])

    Enum.each(mail_confirmation_tokens, fn mail_confirmation_token ->
      multi = Multi.new
      |> Multi.update(:mail_confirmation_token, MailConfirmationToken.changeset(mail_confirmation_token, %{reminder_was_sent: true}))
      |> Multi.merge(fn _ ->
        NotificationEmailConfirmationManager.insert(mail_confirmation_token.user)
      end)
      |> Multi.merge(fn args ->
        MailManager.send(mail_confirmation_token.user, args, :confirmation_reminder)
      end)

      Api.Repo.transaction(multi)
    end)
  end
end
