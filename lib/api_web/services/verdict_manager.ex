import Ecto.Query

defmodule ApiWeb.Services.VerdictManager do
  alias Ecto.Multi
  alias Api.Accounts.User
  alias Api.Moderation.{ModerationReport, Verdict}
  alias Api.Timeline.{Comment, TimelineItem}
  alias ApiWeb.Services.{CommentManager, ImageManager, ModerationManager, TimelineItemManager}

  def insert(attributes) do
    moderation_report = Api.Repo.get(ModerationReport, attributes["moderation_report_id"])
    flaggable_is_timeline_item = moderation_report.timeline_item_id != nil
    flaggable = if flaggable_is_timeline_item,
      do: Api.Repo.one(from p in TimelineItem, where: p.id == ^moderation_report.timeline_item_id),
      else: Api.Repo.one(from c in Comment, where: c.id == ^moderation_report.comment_id, join: ti in assoc(c, :timeline_item), preload: [timeline_item: ti])
    timeline_item = if flaggable_is_timeline_item, do: flaggable, else: flaggable.timeline_item
    previous_verdict = Api.Repo.one(from v in Verdict, where: v.moderation_report_id == ^moderation_report.id, order_by: [desc: v.id], limit: 1)
    flaggable_changeset =  if flaggable_is_timeline_item, do: TimelineItem.private_changeset(flaggable, %{under_moderation: false}), else: Comment.private_changeset(flaggable, %{under_moderation: false})
    timeline_item_changeset = TimelineItem.private_changeset(timeline_item, %{under_moderation: false})
    attributes = Map.put(attributes, "previous_maturity_rating", (if (attributes["action_change_maturity_rating"] && previous_verdict), do: previous_verdict.previous_maturity_rating, else: timeline_item.maturity_rating))
    IO.inspect(attributes)
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
      user = Api.Repo.get(User, moderation_report.indicted_id)
      cond do
        verdict.action_banned_user && user.is_banned == false ->
          user_changeset = User.private_changeset(user, %{is_banned: true})

          Api.Repo.update(user_changeset)
        !verdict.action_banned_user && user.is_banned == true ->
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
        verdict.action_lock_comments && timeline_item.comments_are_locked == false ->
          changeset = TimelineItem.private_changeset(timeline_item, %{comments_are_locked: true})

          Api.Repo.update(changeset)
        !verdict.action_lock_comments && timeline_item.comments_are_locked == true ->
          timeline_item = Api.Repo.preload(timeline_item, [user: [indictions: [:verdicts]]])

          ModerationManager.consider_unlocking_comments(timeline_item)
        true ->
          {:ok, verdict}
      end
    end)
    |> Multi.run(:verdict_change_maturity_rating, fn %{verdict: verdict} ->
      cond do
        verdict.action_change_maturity_rating && timeline_item.maturity_rating != verdict.action_change_maturity_rating ->
          Api.Repo.update(TimelineItem.changeset(timeline_item, %{ maturity_rating: verdict.action_change_maturity_rating }))
        !verdict.action_change_maturity_rating && previous_verdict && previous_verdict.action_change_maturity_rating ->
          Api.Repo.update(TimelineItem.changeset(timeline_item, %{ maturity_rating: previous_verdict.previous_maturity_rating }))
        true ->
          {:ok, verdict}
      end
    end)
    df_multi = delete_flaggable_multi(attributes["action_deleted_flaggable"], flaggable, timeline_item, flaggable_is_timeline_item, previous_verdict)
    if_multi = ignore_flags_multi(attributes["action_ignore_flags"], flaggable, flaggable_is_timeline_item, previous_verdict)
    multi_sequence = delete_media_multi(multi_sequence, attributes["action_delete_media"], attributes["delete_image_ids"], previous_verdict, timeline_item)
    multi_sequence = Multi.append(multi_sequence, df_multi)
    Multi.append(multi_sequence, if_multi)
  end

  defp delete_media_multi(multi, action_delete_media, delete_image_ids, previous_verdict, timeline_item) do
    cond do
      action_delete_media ->
        images = Api.Repo.preload(timeline_item, [post: [:images]]).post.images
        Enum.reduce(images, multi, fn (image, multi) ->
        IO.inspect(image.id)
          cond do
            Enum.member?(delete_image_ids, image.id) && !image.deleted_by_moderator ->
              Multi.append(multi, ImageManager.delete(image, %{deleted_by_moderator: true}, "image_#{image.id}"))
            !Enum.member?(delete_image_ids, image.id) && image.deleted_by_moderator ->
              Multi.append(multi, ImageManager.undelete(image, %{
                deleted: image.deleted_by_user,
                deleted_by_moderator: false
              }, "image_#{image.id}"))
            true ->
              multi
          end
        end)
      !action_delete_media && previous_verdict.action_delete_media ->
        images = Api.Repo.preload(timeline_item, [post: [:images]]).post.images
        Enum.reduce(images, multi, fn (image, multi) ->
          cond do
            image.deleted_by_moderator ->
              Multi.append(multi, ImageManager.undelete(image, %{
                deleted: image.deleted_by_user,
                deleted_by_moderator: false
              }, "image_#{image.id}"))
            true ->
              multi
          end
        end)
      true -> multi
    end
  end

  defp delete_flaggable_multi(action_deleted_flaggable, flaggable, timeline_item, flaggable_is_timeline_item, previous_verdict) do
    cond do
      action_deleted_flaggable && flaggable.deleted_by_moderator == false ->
        if flaggable_is_timeline_item do
          TimelineItemManager.delete(flaggable, %{deleted_by_moderator: true})
        else
          CommentManager.delete(flaggable, %{deleted_by_moderator: true})
        end
      !action_deleted_flaggable && flaggable.deleted_by_moderator == true ->
        if flaggable_is_timeline_item do
          TimelineItemManager.undelete(flaggable, %{
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

  defp ignore_flags_multi(action_ignore_flags, flaggable, flaggable_is_timeline_item, previous_verdict) do
    cond do
      action_ignore_flags && flaggable.ignore_flags == false ->
         flaggable_changeset = if flaggable_is_timeline_item, do: TimelineItem.private_changeset(flaggable, %{ignore_flags: true}), else: Comment.private_changeset(flaggable, %{ignore_flags: true})
         Multi.new
         |> Multi.update(:flaggable, flaggable_changeset)
     !action_ignore_flags && flaggable.ignore_flags == true ->
        flaggable_changeset = if flaggable_is_timeline_item, do: TimelineItem.private_changeset(flaggable, %{ignore_flags: false}), else: Comment.private_changeset(flaggable, %{ignore_flags: false})
        query = if flaggable_is_timeline_item, do: from(mr in ModerationReport, where: mr.timeline_item_id == ^flaggable.id), else: from(mr in ModerationReport, where: mr.comment_id == ^flaggable.id)

        Multi.new
        |> Multi.update(:flaggable, flaggable_changeset)
        |> Multi.update_all(:moderation_reports, query, set: [should_ignore: false])
      true ->
        Multi.new
    end
  end
end
