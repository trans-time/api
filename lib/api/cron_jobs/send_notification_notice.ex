import Ecto.Query

defmodule Api.CronJobs.SendNotificationNotice do
  alias Api.Accounts.User
  alias Api.Mail.{Subscription, SubscriptionType}
  alias Api.Notifications.Notification
  alias ApiWeb.Services.MailManager
  alias Ecto.Multi

  def call() do
    notificationSubscriptionType = Api.Repo.get_by(SubscriptionType, name: "notifications")
    datetime = Timex.shift(Timex.now, days: -1)
    users = Api.Repo.all(from(u in User,
      join: n in Notification,
      join: s in Subscription,
      where: s.user_id == u.id
        and s.subscription_type_id == ^notificationSubscriptionType.id
        and n.user_id == u.id
        and n.is_seen == ^false
        and n.is_emailed == ^false
        and n.updated_at <= ^datetime,
      group_by: [u.id]
    ))

    Enum.each(users, fn user ->
      multi = Multi.new
      |> Multi.update_all(:notifications, from(n in Notification, where: n.user_id == ^user.id), set: [is_emailed: true])
      |> Multi.merge(fn args ->
        MailManager.send(user, args, :notification_notice)
      end)

      Api.Repo.transaction(multi)
    end)
  end
end
