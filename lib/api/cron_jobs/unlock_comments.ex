import Ecto.Query

defmodule Api.CronJobs.UnlockComments do
  alias Api.Timeline.TimelineItem
  alias ApiWeb.Services.ModerationManager

  def call() do
    query = from ti in TimelineItem,
      where: ti.comments_are_locked == ^true,
      join: u in assoc(ti, :user),
      join: i in assoc(u, :indictions),
      join: v in assoc(i, :verdicts),
      preload: [user: {u, indictions: {i, verdicts: v}}]

    Enum.each(Api.Repo.all(query), fn (timeline_item) ->
      ModerationManager.consider_unlocking_comments(timeline_item)
    end)
  end
end
