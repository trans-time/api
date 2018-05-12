import Ecto.Query

defmodule ApiWeb.Services.TimelineItemManager do
  alias Api.Moderation.TextVersion
  alias Api.Accounts.User
  alias Api.Profile.{UserProfile, UserTagSummary, UserTagSummaryTag, UserTagSummaryUser}
  alias Api.Timeline.{Post, Tag, TimelineItem}
  alias ApiWeb.Services.{Libra, PostManager}
  alias Ecto.Multi

  def delete(timeline_item, attributes) do
    timeline_item_changeset = TimelineItem.private_changeset(timeline_item, Map.merge(%{deleted: true, deleted_at: DateTime.utc_now()}, attributes))

    {tags, users} = gather_tags_and_users(timeline_item)
    tag_records = Api.Repo.all(from t in Tag, where: t.name in ^tags)
    tag_record_ids = Enum.map(tag_records, fn (tag) -> tag.id end)

    user_records = Api.Repo.all(from u in User, where: u.username in ^users)
    user_record_ids = Enum.map(user_records, fn (user) -> user.id end)

    user = Api.Repo.preload(timeline_item, :user).user
    user_tag_summary_records = Api.Repo.all(from uts in UserTagSummary, where: (uts.author_id == ^user.id and uts.subject_id in ^[user.id | user_record_ids]) or (uts.subject_id == ^user.id and uts.author_id in ^user_record_ids))
    user_tag_summary_record = Enum.find(user_tag_summary_records, fn (user_tag_summary_record) -> user_tag_summary_record.subject_id == user.id end)
    user_tag_summary_ids = Enum.map(user_tag_summary_records, fn (user_tag_summary_record) -> user_tag_summary_record.id end)

    user_tag_summary_tag_records = Api.Repo.all(from utst in UserTagSummaryTag, where: utst.user_tag_summary_id in ^user_tag_summary_ids and utst.tag_id in ^tag_record_ids)
    user_tag_summary_user_records = Api.Repo.all(from utst in UserTagSummaryUser, where: utst.user_tag_summary_id in ^user_tag_summary_ids and utst.user_id in ^[user.id | user_record_ids])

    multi = Multi.new
    |> Multi.update_all(:user_profile, UserProfile |> where(user_id: ^timeline_item.user_id), inc: [post_count: -1])
    |> Multi.update(:timeline_item, timeline_item_changeset)
    |> Multi.run(:user_tag_summary, fn %{timeline_item: timeline_item} ->
      remove_from_private_timeline_item_ids(user_tag_summary_record, timeline_item)
    end)
    |> Multi.run(:aggregated_tag_records, fn _ ->
      {:ok, tag_records}
    end)
    |> Multi.run(:user_tag_summary_tag_records, fn _ ->
      {:ok, user_tag_summary_tag_records}
    end)
    |> Multi.run(:user_tag_summary_user_records, fn _ ->
      {:ok, user_tag_summary_user_records}
    end)
    |> Multi.run(:put_tag_associations, fn %{timeline_item: timeline_item} ->
      Api.Repo.preload(timeline_item, [:tags, :users])
      |> Ecto.Changeset.change
      |> Ecto.Changeset.put_assoc(:tags, [])
      |> Ecto.Changeset.put_assoc(:users, [])
      |> Api.Repo.update
    end)
    multi = Enum.reduce(tags, multi, fn (tag, multi) ->
      multi
      |> multi_remove_tag_summary_tag("remove_user_tag_summary_tag_#{tag}", tag, :user_tag_summary)
    end)
    multi = Enum.reduce(user_records, multi, fn (user_record, multi) ->
      multi = multi
      |> multi_remove_tag_summary_user("remove_user_tag_summary_user_#{user_record.username}", user_record, :user_tag_summary)
      |> Multi.run("find_user_tag_summary_for_subject_#{user_record.username}", fn %{} ->
        user_tag_summary_record = Enum.find(user_tag_summary_records, fn (user_tag_summary_record) -> user_tag_summary_record.subject_id == user_record.id end)

        remove_from_private_timeline_item_ids(user_tag_summary_record, timeline_item)
      end)

      multi = Enum.reduce(tags, multi, fn (tag, multi) ->
        multi
        |> multi_remove_tag_summary_tag("remove_user_tag_summary_for_subject_#{user_record.username}_with_tag_#{tag}", tag, "find_user_tag_summary_for_subject_#{user_record.username}")
      end)

      Enum.reduce(user_records, multi, fn (subuser_record, multi) ->
        if (user_record == subuser_record) do
          multi
        else
          multi
          |> multi_remove_tag_summary_user("remove_user_tag_summary_for_subject_#{user_record.username}_with_user_#{subuser_record.username}", subuser_record, "find_or_create_user_tag_summary_for_subject_#{user_record.username}")
        end
      end)
    end)
  end

  def undelete(timeline_item, attributes) do
    timeline_item_multi = Multi.new
    |> Multi.update(:timeline_item, TimelineItem.private_changeset(timeline_item, attributes))

    {tags, users} = gather_tags_and_users(timeline_item)
    user = Api.Repo.preload(timeline_item, :user).user

    Multi.append(timeline_item_multi, insert_metadata(tags, users, user))
  end

  def insert(attributes, tags, users, user) do
    timeline_item_multi = Multi.new
    |> Multi.insert(:timeline_item, TimelineItem.changeset(%TimelineItem{}, attributes))

    Multi.append(timeline_item_multi, insert_metadata(tags, users, user))
  end

  defp gather_tags_and_users(timeline_item) do
    text = Api.Repo.preload(timeline_item, :post).post.text
    {PostManager.gather_tags("#", text), PostManager.gather_tags("@", text)}
  end

  defp insert_metadata(tags, users, user) do
    tag_records = Api.Repo.all(from t in Tag, where: t.name in ^tags)
    tag_record_ids = Enum.map(tag_records, fn (tag) -> tag.id end)
    user_records = Api.Repo.all(from u in User, where: u.username in ^users)
    user_record_ids = Enum.map(user_records, fn (user) -> user.id end)
    user_tag_summary_records = Api.Repo.all(from uts in UserTagSummary, where: (uts.author_id == ^user.id and uts.subject_id in ^[user.id | user_record_ids]) or (uts.subject_id == ^user.id and uts.author_id in ^user_record_ids))
    user_tag_summary_record = Enum.find(user_tag_summary_records, fn (user_tag_summary_record) -> user_tag_summary_record.subject_id == user.id end)
    user_tag_summary_ids = Enum.map(user_tag_summary_records, fn (user_tag_summary_record) -> user_tag_summary_record.id end)

    user_tag_summary_tag_records = Api.Repo.all(from utst in UserTagSummaryTag, where: utst.user_tag_summary_id in ^user_tag_summary_ids and utst.tag_id in ^tag_record_ids)
    user_tag_summary_user_records = Api.Repo.all(from utst in UserTagSummaryUser, where: utst.user_tag_summary_id in ^user_tag_summary_ids and utst.user_id in ^[user.id | user_record_ids])

    multi = Multi.new
    |> Multi.update_all(:user_profile, Ecto.assoc(user, :user_profile), inc: [post_count: 1])
    |> Multi.run(:user_tag_summary, fn %{timeline_item: timeline_item} ->
      add_or_remove_from_private_timeline_item_ids(user_tag_summary_record, timeline_item)
    end)
    |> Multi.run(:user_tag_summary_tag_records, fn _ ->
      {:ok, user_tag_summary_tag_records}
    end)
    |> Multi.run(:user_tag_summary_user_records, fn _ ->
      {:ok, user_tag_summary_user_records}
    end)
    multi = Enum.reduce(tags, multi, fn (tag, multi) ->
      multi
      |> Multi.run("find_or_create_tag_#{tag}", fn %{} ->
        tag_record = Enum.find(tag_records, fn (tag_record) -> tag_record.name == tag end)

        if (tag_record != nil), do: {:ok, tag_record}, else: Api.Repo.insert(Tag.changeset(%Tag{}, %{name: tag}))
      end)
    end)
    |> Multi.run(:aggregated_tag_records, fn args ->
      {:ok, Enum.map(tags, fn (tag) -> args["find_or_create_tag_#{tag}"] end)}
    end)
    |> Multi.run(:put_tag_associations, fn %{timeline_item: timeline_item, aggregated_tag_records: aggregated_tag_records} ->
      Api.Repo.preload(timeline_item, [:tags, :users])
      |> Ecto.Changeset.change
      |> Ecto.Changeset.put_assoc(:tags, aggregated_tag_records)
      |> Ecto.Changeset.put_assoc(:users, [user | user_records])
      |> Api.Repo.update
    end)
    multi = Enum.reduce(tags, multi, fn (tag, multi) ->
      multi
      |> multi_find_or_create_tag_summary_tag("find_or_create_user_tag_summary_tag_#{tag}", tag, :user_tag_summary)
    end)
    Enum.reduce(user_records, multi, fn (user_record, multi) ->
      multi = multi
      |> multi_find_or_create_tag_summary_user("find_or_create_user_tag_summary_user_#{user_record.username}", user_record, :user_tag_summary)
      |> Multi.run("find_or_create_user_tag_summary_for_subject_#{user_record.username}", fn %{timeline_item: timeline_item} ->
        user_tag_summary_record = Enum.find(user_tag_summary_records, fn (user_tag_summary_record) -> user_tag_summary_record.subject_id == user_record.id end)

        if (user_tag_summary_record != nil) do
          add_or_remove_from_private_timeline_item_ids(user_tag_summary_record, timeline_item)
        else
          private_timeline_item_ids = if (timeline_item.private), do: [timeline_item.id], else: []
          Api.Repo.insert(UserTagSummary.changeset(%UserTagSummary{}, %{author_id: user.id, subject_id: user_record.id, private_timeline_item_ids: private_timeline_item_ids }))
        end
      end)

      multi = Enum.reduce(tags, multi, fn (tag, multi) ->
        multi
        |> multi_find_or_create_tag_summary_tag("find_or_create_user_tag_summary_for_subject_#{user_record.username}_with_tag_#{tag}", tag, "find_or_create_user_tag_summary_for_subject_#{user_record.username}")
      end)

      Enum.reduce([user | user_records], multi, fn (subuser_record, multi) ->
        if (user_record == subuser_record) do
          multi
        else
          multi
          |> multi_find_or_create_tag_summary_user("find_or_create_user_tag_summary_for_subject_#{user_record.username}_with_user_#{subuser_record.username}", subuser_record, "find_or_create_user_tag_summary_for_subject_#{user_record.username}")
        end
      end)
    end)
  end

  def update(timeline_item, attributes, old_tags, current_tags, old_users, current_users, user) do
    timeline_item_changeset = TimelineItem.changeset(timeline_item, attributes)
    timeline_item_private_changeset = TimelineItem.private_changeset(timeline_item, %{ignore_flags: false})

    added_tags = current_tags -- old_tags
    removed_tags = old_tags -- current_tags
    all_tags = Enum.uniq(old_tags ++ current_tags)
    tag_records = Api.Repo.all(from t in Tag, where: t.name in ^all_tags)
    tag_record_ids = Enum.map(tag_records, fn (tag) -> tag.id end)

    added_users = current_users -- old_users
    removed_users = old_users -- current_users
    all_users = Enum.uniq(old_users ++ current_users ++ [user.username])
    user_records = Api.Repo.all(from u in User, where: u.username in ^all_users)
    user_record_ids = Enum.map(user_records, fn (user) -> user.id end)

    user_tag_summary_records = Api.Repo.all(from uts in UserTagSummary, where: (uts.author_id == ^user.id and uts.subject_id in ^[user.id | user_record_ids]) or (uts.subject_id == ^user.id and uts.author_id in ^user_record_ids))
    user_tag_summary_record = Enum.find(user_tag_summary_records, fn (user_tag_summary_record) -> user_tag_summary_record.subject_id == user.id end)
    user_tag_summary_ids = Enum.map(user_tag_summary_records, fn (user_tag_summary_record) -> user_tag_summary_record.id end)

    user_tag_summary_tag_records = Api.Repo.all(from utst in UserTagSummaryTag, where: utst.user_tag_summary_id in ^user_tag_summary_ids and utst.tag_id in ^tag_record_ids)
    user_tag_summary_user_records = Api.Repo.all(from utst in UserTagSummaryUser, where: utst.user_tag_summary_id in ^user_tag_summary_ids and utst.user_id in ^user_record_ids)

    multi = Multi.new
    |> Multi.update(:timeline_item, Ecto.Changeset.merge(timeline_item_changeset, timeline_item_private_changeset))
    |> Multi.run(:user_tag_summary, fn %{timeline_item: timeline_item} ->
      add_or_remove_from_private_timeline_item_ids(user_tag_summary_record, timeline_item)
    end)
    |> Multi.run(:user_tag_summary_tag_records, fn _ ->
      {:ok, user_tag_summary_tag_records}
    end)
    |> Multi.run(:user_tag_summary_user_records, fn _ ->
      {:ok, user_tag_summary_user_records}
    end)
    multi = Enum.reduce(added_tags, multi, fn (tag, multi) ->
      multi
      |> Multi.run("find_or_create_tag_#{tag}", fn %{} ->
        tag_record = Enum.find(tag_records, fn (tag_record) -> tag_record.name == tag end)

        if (tag_record != nil), do: {:ok, tag_record}, else: Api.Repo.insert(Tag.changeset(%Tag{}, %{name: tag}))
      end)
    end)
    |> Multi.run(:aggregated_tag_records, fn args ->
      {:ok, Enum.uniq(Enum.map(added_tags, fn (tag) -> args["find_or_create_tag_#{tag}"] end) ++ tag_records)}
    end)
    |> Multi.run(:put_tag_associations, fn %{timeline_item: timeline_item, aggregated_tag_records: aggregated_tag_records} ->
      timeline_item = Api.Repo.preload(timeline_item, [:tags, :users])
      added_tag_records = Enum.map(added_tags, fn (tag) -> Enum.find(aggregated_tag_records, fn (tag_record) -> tag_record.name == tag end) end)
      removed_tag_records = Enum.map(removed_tags, fn (tag) -> Enum.find(aggregated_tag_records, fn (tag_record) -> tag_record.name == tag end) end)
      added_user_records = Enum.map(added_users, fn (username) -> Enum.find(user_records, fn (user_record) -> user_record.username == username end)end)
      removed_user_records = Enum.map(removed_users, fn (username) -> Enum.find(user_records, fn (user_record) -> user_record.username == username end)end)
      timeline_item

      |> Ecto.Changeset.change
      |> Ecto.Changeset.put_assoc(:tags, (timeline_item.tags ++ added_tag_records) -- removed_tag_records)
      |> Ecto.Changeset.put_assoc(:users, (timeline_item.users ++ added_user_records) -- removed_user_records)
      |> Api.Repo.update
    end)
    multi = Enum.reduce(added_tags, multi, fn (tag, multi) ->
      multi
      |> multi_find_or_create_tag_summary_tag("find_or_create_user_tag_summary_tag_#{tag}", tag, :user_tag_summary)
    end)
    multi = Enum.reduce(removed_tags, multi, fn (tag, multi) ->
      multi
      |> multi_remove_tag_summary_tag("remove_user_tag_summary_tag_#{tag}", tag, :user_tag_summary)
    end)
    multi = Enum.reduce(removed_users, multi, fn (username, multi) ->
      user_record = Enum.find(user_records, fn (user_record) -> user_record.username == username end)

      if (user_record == nil) do
        multi
      else
        multi = multi
        |> multi_remove_tag_summary_user("remove_user_tag_summary_user_#{user_record.username}", user_record, :user_tag_summary)
        |> Multi.run("find_user_tag_summary_for_subject_#{user_record.username}", fn %{} ->
          user_tag_summary_record = Enum.find(user_tag_summary_records, fn (user_tag_summary_record) -> user_tag_summary_record.subject_id == user_record.id end)

          remove_from_private_timeline_item_ids(user_tag_summary_record, timeline_item)
        end)

        multi = Enum.reduce(all_tags, multi, fn (tag, multi) ->
          multi
          |> multi_remove_tag_summary_tag("remove_user_tag_summary_for_subject_#{user_record.username}_with_tag_#{tag}", tag, "find_user_tag_summary_for_subject_#{user_record.username}")
        end)

        Enum.reduce(all_users, multi, fn (subuser_username, multi) ->
          subuser_record = Enum.find(user_records, fn (user_record) -> user_record.username == subuser_username end)
          if (user_record == subuser_record || subuser_record == nil) do
            multi
          else
            multi
            |> multi_remove_tag_summary_user("remove_user_tag_summary_for_subject_#{user_record.username}_with_user_#{subuser_record.username}", subuser_record, "find_user_tag_summary_for_subject_#{user_record.username}")
          end
        end)
      end
    end)
    multi = Enum.reduce(current_users -- added_users, multi, fn (username, multi) ->
      user_record = Enum.find(user_records, fn (user_record) -> user_record.username == username end)

      if (user_record == nil) do
        multi
      else

        multi = multi
        |> multi_find_or_create_tag_summary_user("find_or_create_user_tag_summary_user_#{user_record.username}", user_record, :user_tag_summary)
        |> Multi.run("find_or_create_user_tag_summary_for_subject_#{user_record.username}", fn %{} ->
          user_tag_summary_record = Enum.find(user_tag_summary_records, fn (user_tag_summary_record) -> user_tag_summary_record.subject_id == user_record.id end)

          if (user_tag_summary_record != nil) do
            add_or_remove_from_private_timeline_item_ids(user_tag_summary_record, timeline_item)
          else
            private_timeline_item_ids = if (timeline_item.private), do: [timeline_item.id], else: []
            Api.Repo.insert(UserTagSummary.changeset(%UserTagSummary{}, %{author_id: user.id, subject_id: user_record.id, private_timeline_item_ids: private_timeline_item_ids }))
          end
        end)

        multi = Enum.reduce(added_tags, multi, fn (tag, multi) ->
          multi
          |> multi_find_or_create_tag_summary_tag("find_or_create_user_tag_summary_for_subject_#{user_record.username}_with_tag_#{tag}", tag, "find_or_create_user_tag_summary_for_subject_#{user_record.username}")
        end)
        multi = Enum.reduce(removed_tags, multi, fn (tag, multi) ->
          multi
          |> multi_remove_tag_summary_tag("remove_user_tag_summary_for_subject_#{user_record.username}_with_tag_#{tag}", tag, "find_or_create_user_tag_summary_for_subject_#{user_record.username}")
        end)

        Enum.reduce(added_users, multi, fn (subuser_username, multi) ->
          subuser_record = Enum.find(user_records, fn (user_record) -> user_record.username == subuser_username end)
          if (user_record == subuser_record || subuser_record == nil) do
            multi
          else
            multi
            |> multi_find_or_create_tag_summary_user("find_or_create_user_tag_summary_for_subject_#{user_record.username}_with_user_#{subuser_record.username}", user_record, "find_or_create_user_tag_summary_for_subject_#{user_record.username}")
          end
        end)

        Enum.reduce(removed_users, multi, fn (subuser_username, multi) ->
          subuser_record = Enum.find(user_records, fn (user_record) -> user_record.username == subuser_username end)
          if (user_record == subuser_record || subuser_record == nil) do
            multi
          else
            multi
            |> multi_remove_tag_summary_user("remove_user_tag_summary_for_subject_#{user_record.username}_with_user_#{subuser_record.username}", subuser_record, "find_or_create_user_tag_summary_for_subject_#{user_record.username}")
          end
        end)
      end
    end)
    Enum.reduce(added_users, multi, fn (username, multi) ->
      user_record = Enum.find(user_records, fn (user_record) -> user_record.username == username end)

      if (user_record == nil) do
        multi
      else
        multi = multi
        |> multi_find_or_create_tag_summary_user("find_or_create_user_tag_summary_user_#{user_record.username}", user_record, :user_tag_summary)
        |> Multi.run("find_or_create_user_tag_summary_for_subject_#{user_record.username}", fn %{} ->
          user_tag_summary_record = Enum.find(user_tag_summary_records, fn (user_tag_summary_record) -> user_tag_summary_record.subject_id == user_record.id end)

          if (user_tag_summary_record != nil) do
            add_or_remove_from_private_timeline_item_ids(user_tag_summary_record, timeline_item)
          else
            private_timeline_item_ids = if (timeline_item.private), do: [timeline_item.id], else: []
            Api.Repo.insert(UserTagSummary.changeset(%UserTagSummary{}, %{author_id: user.id, subject_id: user_record.id, private_timeline_item_ids: private_timeline_item_ids }))
          end
        end)

        multi = Enum.reduce(current_tags, multi, fn (tag, multi) ->
          multi
          |> multi_find_or_create_tag_summary_tag("find_or_create_user_tag_summary_for_subject_#{user_record.username}_with_tag_#{tag}", tag, "find_or_create_user_tag_summary_for_subject_#{user_record.username}")
        end)

        Enum.reduce([user.username | current_users], multi, fn (subuser_username, multi) ->
          subuser_record = Enum.find(user_records, fn (user_record) -> user_record.username == subuser_username end)
          if (user_record == subuser_record || subuser_record == nil) do
            multi
          else
            multi
            |> multi_find_or_create_tag_summary_user("find_or_create_user_tag_summary_for_subject_#{user_record.username}_with_user_#{subuser_record.username}", subuser_record, "find_or_create_user_tag_summary_for_subject_#{user_record.username}")
          end
        end)
      end
    end)
  end

  defp add_or_remove_from_private_timeline_item_ids(user_tag_summary_record, timeline_item) do
    private_timeline_item_ids = if (timeline_item.private), do: Enum.uniq([timeline_item.id | user_tag_summary_record.private_timeline_item_ids]), else: user_tag_summary_record.private_timeline_item_ids -- [timeline_item.id]

    update_with_private_timeline_item_ids(user_tag_summary_record, private_timeline_item_ids)
  end

  defp remove_from_private_timeline_item_ids(user_tag_summary_record, timeline_item) do
    private_timeline_item_ids = user_tag_summary_record.private_timeline_item_ids -- [timeline_item.id]

    update_with_private_timeline_item_ids(user_tag_summary_record, private_timeline_item_ids)
  end

  defp update_with_private_timeline_item_ids(user_tag_summary_record, private_timeline_item_ids) do
    if (Enum.empty?(private_timeline_item_ids -- user_tag_summary_record.private_timeline_item_ids)) do
      {:ok, user_tag_summary_record}
    else
      Api.Repo.update(UserTagSummary.changeset(user_tag_summary_record, %{private_timeline_item_ids: private_timeline_item_ids}))
    end
  end

  defp multi_find_or_create_tag_summary_tag(multi, multi_name, tag_name, user_tag_summary_record_multi_name) do
    multi
    |> Multi.run(multi_name, fn multi_args ->
      timeline_item = multi_args.timeline_item
      user_tag_summary_tag_records = multi_args.user_tag_summary_tag_records
      user_tag_summary_record = multi_args[user_tag_summary_record_multi_name]
      tag_record = Enum.find(multi_args.aggregated_tag_records, fn (tag_record) -> tag_record.name == tag_name end)
      user_tag_summary_tag_record = Enum.find(user_tag_summary_tag_records, fn (user_tag_summary_tag_record) ->
        user_tag_summary_tag_record.user_tag_summary_id == user_tag_summary_record.id && user_tag_summary_tag_record.tag_id == tag_record.id
      end)

      if (user_tag_summary_tag_record != nil) do
        Api.Repo.update(UserTagSummaryTag.changeset(user_tag_summary_tag_record, %{timeline_item_ids: [timeline_item.id | user_tag_summary_tag_record.timeline_item_ids]}))
      else
        Api.Repo.insert(UserTagSummaryTag.changeset(%UserTagSummaryTag{}, %{user_tag_summary_id: user_tag_summary_record.id, tag_id: tag_record.id, timeline_item_ids: [timeline_item.id]}))
      end
    end)
  end

  defp multi_find_or_create_tag_summary_user(multi, multi_name, user_record, user_tag_summary_record_multi_name) do
    multi
    |> Multi.run(multi_name, fn multi_args ->
      timeline_item = multi_args.timeline_item
      user_tag_summary_user_records = multi_args.user_tag_summary_user_records
      user_tag_summary_record = multi_args[user_tag_summary_record_multi_name]
      user_tag_summary_user_record = Enum.find(user_tag_summary_user_records, fn (user_tag_summary_user_record) ->
        user_tag_summary_user_record.user_tag_summary_id == user_tag_summary_record.id && user_tag_summary_user_record.user_id == user_record.id
      end)

      if (user_tag_summary_user_record != nil) do
        Api.Repo.update(UserTagSummaryUser.changeset(user_tag_summary_user_record, %{timeline_item_ids: [timeline_item.id | user_tag_summary_user_record.timeline_item_ids]}))
      else
        Api.Repo.insert(UserTagSummaryUser.changeset(%UserTagSummaryUser{}, %{user_tag_summary_id: user_tag_summary_record.id, user_id: user_record.id, timeline_item_ids: [timeline_item.id]}))
      end
    end)
  end

  defp multi_remove_tag_summary_tag(multi, multi_name, tag_name, user_tag_summary_record_multi_name) do
    multi
    |> Multi.run(multi_name, fn multi_args ->
      timeline_item = multi_args.timeline_item
      user_tag_summary_tag_records = multi_args.user_tag_summary_tag_records
      user_tag_summary_record = multi_args[user_tag_summary_record_multi_name]
      tag_record = Enum.find(multi_args.aggregated_tag_records, fn (tag_record) -> tag_record.name == tag_name end)
      user_tag_summary_tag_record = Enum.find(user_tag_summary_tag_records, fn (user_tag_summary_tag_record) ->
        user_tag_summary_tag_record.user_tag_summary_id == user_tag_summary_record.id && user_tag_summary_tag_record.tag_id == tag_record.id
      end)
      timeline_item_ids = user_tag_summary_tag_record.timeline_item_ids -- [timeline_item.id]

      if (Enum.empty?(timeline_item_ids)) do
        Api.Repo.delete(user_tag_summary_tag_record)
      else
        Api.Repo.update(UserTagSummaryTag.changeset(user_tag_summary_tag_record, %{timeline_item_ids: timeline_item_ids}))
      end
    end)
  end

  defp multi_remove_tag_summary_user(multi, multi_name, user_record, user_tag_summary_record_multi_name) do
    multi
    |> Multi.run(multi_name, fn multi_args ->
      timeline_item = multi_args.timeline_item
      user_tag_summary_user_records = multi_args.user_tag_summary_user_records
      user_tag_summary_record = multi_args[user_tag_summary_record_multi_name]

      user_tag_summary_user_record = Enum.find(user_tag_summary_user_records, fn (user_tag_summary_user_record) ->
        user_tag_summary_user_record.user_tag_summary_id == user_tag_summary_record.id && user_tag_summary_user_record.user_id == user_record.id
      end)
      timeline_item_ids = user_tag_summary_user_record.timeline_item_ids -- [timeline_item.id]

      if (Enum.empty?(timeline_item_ids)) do
        Api.Repo.delete(user_tag_summary_user_record)
      else
        Api.Repo.update(UserTagSummaryUser.changeset(user_tag_summary_user_record, %{timeline_item_ids: timeline_item_ids}))
      end
    end)
  end
end
