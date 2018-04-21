defmodule ApiWeb.Services.ModerationManager do
  alias Api.Accounts.User
  alias Api.Timeline.Post

  def consider_unlocking_comments(post) do
    if (post.comments_are_locked) do
      now = DateTime.utc_now()

      if (!Enum.any?(post.timeline_item.user.indictions, fn (indiction) ->
        latest_verdict = Enum.at(indiction.verdicts, -1)
        until = latest_verdict.lock_comments_until

        latest_verdict.action_lock_comments && (until == nil || (until != nil && DateTime.compare(until, now) == :gt))
      end)) do
        changeset = Post.private_changeset(post, %{comments_are_locked: false})

        Api.Repo.update(changeset)
      else
        {:ok, post}
      end
    else
      {:ok, post}
    end
  end

  def consider_unbanning_user(user) do
    if (user.is_banned) do
      now = DateTime.utc_now()

      if (!Enum.any?(user.indictions, fn (indiction) ->
        latest_verdict = Enum.at(indiction.verdicts, -1)
        until = latest_verdict.ban_user_until

        latest_verdict.action_banned_user && (until == nil || (until != nil && DateTime.compare(until, now) == :gt))
      end)) do
        changeset = User.private_changeset(user, %{is_banned: false})

        Api.Repo.update(changeset)
      else
        {:ok, user}
      end
    else
      {:ok, user}
    end
  end
end
