import Ecto.Query

defmodule Api.CronJobs.UnlockComments do
  alias Api.Timeline.Post
  alias ApiWeb.Services.ModerationManager

  def call() do
    query = from p in Post,
      where: p.comments_are_locked == ^true,
      join: ti in assoc(p, :timeline_item),
      join: u in assoc(ti, :user),
      join: i in assoc(u, :indictions),
      join: v in assoc(i, :verdicts),
      preload: [timeline_item: {ti, user: {u, indictions: {i, verdicts: v}}}]

    Enum.each(Api.Repo.all(query), fn (post) ->
      ModerationManager.consider_unlocking_comments(post)
    end)
  end
end
