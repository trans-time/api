import Ecto.Query

defmodule Api.CronJobs.UnlockUsers do
  alias Api.Accounts.User
  alias Api.Mail.MailUnlockToken

  def call() do
    Api.Repo.delete_all(MailUnlockToken)

    from(u in User, where: u.is_locked == ^true)
    |> Api.Repo.update_all(set: [is_locked: false])
  end
end
