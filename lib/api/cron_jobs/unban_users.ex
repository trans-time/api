import Ecto.Query

defmodule Api.CronJobs.UnbanUsers do
  alias Api.Accounts.User
  alias ApiWeb.Services.ModerationManager

  def call() do
    query = from u in User,
      where: u.is_banned == ^true,
      join: i in assoc(u, :indictions),
      join: v in assoc(i, :verdicts),
      preload: [indictions: {i, verdicts: v}]

    Enum.each(Api.Repo.all(query), fn (user) ->
      ModerationManager.consider_unbanning_user(user)
    end)
  end
end
