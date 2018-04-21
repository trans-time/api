import Ecto.Query

defmodule ApiWeb.Services.VerdictManager do
  alias Ecto.Multi
  alias Api.Accounts.User
  alias Api.Moderation.{ModerationReport, Verdict}
  alias Api.Timeline.{Comment, Post, TimelineItem}
  alias ApiWeb.Services.{CommentManager, ModerationManager, PostManager}

  def insert(attributes) do
    moderation_report = Api.Repo.get(ModerationReport, attributes["moderation_report_id"])
    flaggable_is_post = moderation_report.post_id != nil
    flaggable = if flaggable_is_post,
      do: Api.Repo.one(from p in Post, where: p.id == ^moderation_report.post_id, join: ti in assoc(p, :timeline_item), preload: [timeline_item: ti]),
      else: Api.Repo.one(from c in Comment, where: c.id == ^moderation_report.comment_id, join: p in assoc(c, :post), join: ti in assoc(p, :timeline_item), preload: [post: {p, timeline_item: ti}])
    post = if flaggable_is_post, do: flaggable, else: flaggable.post
    timeline_item = post.timeline_item
    previous_verdict = Api.Repo.one(from v in Verdict, where: v.moderation_report_id == ^moderation_report.id, order_by: [desc: v.id], limit: 1)
    flaggable_changeset =  if flaggable_is_post, do: Post.private_changeset(flaggable, %{under_moderation: false}), else: Comment.private_changeset(flaggable, %{under_moderation: false})
    timeline_item_changeset = TimelineItem.private_changeset(timeline_item, %{under_moderation: false})
    verdict_changeset = Verdict.changeset(%Verdict{}, attributes)
    moderation_report_changeset = ModerationReport.changeset(moderation_report, %{
      resolved: true,
      was_violation: attributes["was_violation"],
      should_ignore: flaggable.ignore_flags
    })

    multi_sequence = Multi.new
    |> Multi.update(:verdict_moderation_report, moderation_report_changeset)
    |> Multi.update(:verdict_flaggable, flaggable_changeset)
    |> Multi.update(:verdict_timeline_item, timeline_item_changeset)
    |> Multi.insert(:verdict, verdict_changeset)
    |> Multi.run(:verdict_ban_user, fn %{verdict: verdict} ->
      cond do
        verdict.action_banned_user && (previous_verdict == nil || previous_verdict.action_banned_user == false) ->
          user = Api.Repo.get(User, moderation_report.indicted_id)
          user_changeset = User.private_changeset(user, %{is_banned: true})

          Api.Repo.update(user_changeset)
        previous_verdict != nil && previous_verdict.action_banned_user == true && !verdict.action_banned_user ->
          query = from u in User,
            where: u.id == ^moderation_report.indicted_id,
            join: i in assoc(u, :indictions),
            join: v in assoc(i, :verdicts),
            preload: [indictions: {i, verdicts: v}]
          user = Api.Repo.one(query)

          ModerationManager.consider_unbanning_user(user)
        true ->
          {:ok, verdict}
      end
    end)
    |> Multi.run(:verdict_lock_comments, fn %{verdict: verdict} ->
      cond do
        verdict.action_lock_comments && (previous_verdict == nil || previous_verdict.action_lock_comments == false) ->
          changeset = Post.private_changeset(post, %{comments_are_locked: true})

          Api.Repo.update(changeset)
        previous_verdict != nil && previous_verdict.action_lock_comments == true && !verdict.action_lock_comments ->
          post = Api.Repo.preload(post, [timeline_item: [user: [indictions: [:verdicts]]]])

          ModerationManager.consider_unlocking_comments(post)
        true ->
          {:ok, verdict}
        end
    end)
    df_multi = delete_flaggable_multi(attributes["action_deleted_flaggable"], flaggable, timeline_item, flaggable_is_post, previous_verdict)
    if_multi = ignore_flags_multi(attributes["action_ignore_flags"], flaggable, flaggable_is_post, previous_verdict)
    multi_sequence = Multi.append(multi_sequence, df_multi)
    Multi.append(multi_sequence, if_multi)
  end

  defp delete_flaggable_multi(action_deleted_flaggable, flaggable, timeline_item, flaggable_is_post, previous_verdict) do
    cond do
      action_deleted_flaggable && (previous_verdict == nil || previous_verdict.action_deleted_flaggable == false) ->
        if flaggable_is_post do
          PostManager.delete(flaggable, timeline_item, %{deleted_by_moderator: true})
        else
          CommentManager.delete(flaggable, %{deleted_by_moderator: true})
        end
      !action_deleted_flaggable && previous_verdict != nil && previous_verdict.action_deleted_flaggable == true ->
        if flaggable_is_post do
          PostManager.undelete(flaggable, timeline_item, %{
            deleted: flaggable.deleted_by_user,
            deleted_by_moderator: false
          })
        else
          CommentManager.undelete(flaggable, %{
            deleted: flaggable.deleted_by_user,
            deleted_by_moderator: false
          })
        end
      true ->
        Multi.new
    end
  end

  defp ignore_flags_multi(action_ignore_flags, flaggable, flaggable_is_post, previous_verdict) do
    cond do
      action_ignore_flags && (previous_verdict == nil || previous_verdict.action_ignore_flags == false) ->
         flaggable_changeset = if flaggable_is_post, do: Post.private_changeset(flaggable, %{ignore_flags: true}), else: Comment.private_changeset(flaggable, %{ignore_flags: true})
         Multi.new
         |> Multi.update(:flaggable, flaggable_changeset)
     !action_ignore_flags && previous_verdict != nil && previous_verdict.action_ignore_flags == true ->
        flaggable_changeset = if flaggable_is_post, do: Post.private_changeset(flaggable, %{ignore_flags: false}), else: Comment.private_changeset(flaggable, %{ignore_flags: false})
        query = if flaggable_is_post, do: from(mr in ModerationReport, where: mr.post_id == ^flaggable.id), else: from(mr in ModerationReport, where: mr.comment_id == ^flaggable.id)

        Multi.new
        |> Multi.update(:flaggable, flaggable_changeset)
        |> Multi.update_all(:moderation_reports, query, set: [should_ignore: false])
      true ->
        Multi.new
    end
  end
end
