defmodule ApiWeb.Services.ModerationManager do
  alias Api.Accounts.User
  alias Api.Timeline.TimelineItem

  def consider_unlocking_comments(timeline_item) do
    now = DateTime.utc_now()

    if (!Enum.any?(timeline_item.user.indictions, fn (indiction) ->
      latest_verdict = Enum.at(indiction.verdicts, -1)
      until = latest_verdict.lock_comments_until

      latest_verdict.action_lock_comments && (until == nil || (until != nil && DateTime.compare(until, now) == :gt))
    end)) do
      changeset = TimelineItem.private_changeset(timeline_item, %{comments_locked: false})

      Api.Repo.update(changeset)
    end
  end

  def consider_unbanning_user(user) do
    now = DateTime.utc_now()

    if (!Enum.any?(user.indictions, fn (indiction) ->
      latest_verdict = Enum.at(indiction.verdicts, -1)
      until = latest_verdict.ban_user_until

      latest_verdict.action_banned_user && (until == nil || (until != nil && DateTime.compare(until, now) == :gt))
    end)) do
      changeset = User.private_changeset(user, %{is_banned: false})

      Api.Repo.update(changeset)
    end
  end
end
