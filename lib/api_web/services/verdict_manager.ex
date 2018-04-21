import Ecto.Query

defmodule ApiWeb.Services.VerdictManager do
  alias Ecto.Multi
  alias Api.Accounts.User
  alias Api.Moderation.{ModerationReport, Verdict}
  alias Api.Timeline.{Comment, Post, TimelineItem}
  alias ApiWeb.Services.ModerationManager

  def insert(attributes) do
    moderation_report = Api.Repo.get(ModerationReport, attributes["moderation_report_id"])
    verdict_changeset = Verdict.changeset(%Verdict{}, attributes)
    moderation_report_changeset = ModerationReport.changeset(moderation_report, %{
      resolved: true,
      was_violation: attributes["was_violation"]
    })

    Multi.new
    |> Multi.update(:moderation_report, moderation_report_changeset)
    |> Multi.insert(:verdict, verdict_changeset)
    |> Multi.run(:consequences, fn %{verdict: verdict} ->
      if (verdict.action_banned_user) do
        user = Api.Repo.get(User, moderation_report.indicted_id)
        changeset = User.private_changeset(user, %{is_banned: true})

        Api.Repo.update(changeset)
      else
        query = from u in User,
          where: u.id == ^moderation_report.indicted_id,
          join: i in assoc(u, :indictions),
          join: v in assoc(i, :verdicts),
          preload: [indictions: {i, verdicts: v}]
        user = Api.Repo.one(query)

        ModerationManager.consider_unbanning_user(user)
      end

      timeline_item = if moderation_report.post_id != nil,
        do: Api.Repo.one(from p in Post, where: p.id == ^moderation_report.post_id, join: ti in assoc(p, :timeline_item), preload: [timeline_item: ti]).timeline_item,
        else: Api.Repo.one(from c in Comment, where: c.id == ^moderation_report.comment_id, join: p in assoc(c, :post), join: ti in assoc(p, :timeline_item), preload: [post: {p, timeline_item: ti}]).post.timeline_item

      if (verdict.lock_comments_until) do
        timeline_item = Api.Repo.get(TimelineItem, timeline_item.id)
        changeset = TimelineItem.private_changeset(timeline_item, %{comments_locked: true})

        Api.Repo.update(changeset)
      else
        query = from ti in TimelineItem,
          where: ti.id == ^timeline_item.id,
          join: u in assoc(ti, :user),
          join: i in assoc(u, :indictions),
          join: v in assoc(i, :verdicts),
          preload: [user: {u, indictions: {i, verdicts: v}}]
        timeline_item = Api.Repo.one(query)

        ModerationManager.consider_unlocking_comments(timeline_item)
      end
    end)
  end
end
