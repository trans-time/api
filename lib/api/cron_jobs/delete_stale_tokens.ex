import Ecto.Query

defmodule Api.CronJobs.DeleteStaleTokens do
  alias Api.Mail.{MailSubscriptionToken, MailPasswordResetToken}

  def call() do
    datetime = Timex.shift(Timex.now, days: -30)
    from(mst in MailSubscriptionToken, where: mst.inserted_at <= ^datetime)
    |> Api.Repo.delete_all

    datetime = Timex.shift(Timex.now, days: -1)
    from(mst in MailPasswordResetToken, where: mst.inserted_at <= ^datetime)
    |> Api.Repo.delete_all
  end
end
