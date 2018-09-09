import Ecto.Query

defmodule Api.CronJobs.DeleteStaleTokens do
  alias Api.Mail.MailSubscriptionToken

  def call() do
    datetime = Timex.shift(Timex.now, days: -30)
    from(mst in MailSubscriptionToken, where: mst.inserted_at <= ^datetime)
    |> Api.Repo.delete_all
  end
end
