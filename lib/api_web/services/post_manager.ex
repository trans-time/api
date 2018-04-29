import Ecto.Query

defmodule ApiWeb.Services.PostManager do
  alias Api.Moderation.TextVersion
  alias Api.Accounts.User
  alias Api.Profile.{UserProfile, UserTagSummary, UserTagSummaryTag, UserTagSummaryUser}
  alias Api.Timeline.{Post, Tag, TimelineItem}
  alias ApiWeb.Services.Libra
  alias Ecto.Multi

  def delete(record, timeline_item, attributes) do
    post_changeset = Post.private_changeset(record, Map.merge(%{deleted: true}, attributes))
    timeline_item_changeset = TimelineItem.private_changeset(timeline_item, %{deleted: true})

    Multi.new
    |> Multi.update_all(:user_profile, UserProfile |> where(user_id: ^timeline_item.user_id), inc: [post_count: -1])
    |> Multi.update(:timeline_item, timeline_item_changeset)
    |> Multi.update(:post, post_changeset)
  end

  def undelete(record, timeline_item, attributes) do
    post_changeset = Post.private_changeset(record, attributes)
    timeline_item_changeset = TimelineItem.private_changeset(timeline_item, attributes)

    Multi.new
    |> Multi.update_all(:user_profile, UserProfile |> where(user_id: ^timeline_item.user_id), inc: [post_count: 1])
    |> Multi.update(:timeline_item, timeline_item_changeset)
    |> Multi.update(:post, post_changeset)
  end

  def insert(attributes, user) do
    post_changeset = Post.changeset(%Post{}, attributes)
    timeline_item_changeset = TimelineItem.changeset(%TimelineItem{}, %{
      date: attributes["date"],
      private: attributes["private"] || false,
      user_id: attributes["user_id"]
    })
    tags = gather_tags(post_changeset.changes.text, "#")
    tag_records = Api.Repo.all(from t in Tag, where: t.name in ^tags)
    tag_record_ids = Enum.map(tag_records, fn (tag) -> tag.id end)
    users = gather_tags(post_changeset.changes.text, "@")
    user_records = Api.Repo.all(from u in User, where: u.username in ^users)
    user_record_ids = Enum.map(user_records, fn (user) -> user.id end)
    user_tag_summary_records = Api.Repo.all(from uts in UserTagSummary, where: (uts.author_id == ^user.id and uts.subject_id in ^[user.id | user_record_ids]) or (uts.subject_id == ^user.id and uts.author_id in ^user_record_ids))
    user_tag_summary_record = Enum.find(user_tag_summary_records, fn (user_tag_summary_record) -> user_tag_summary_record.subject_id == user.id end)
    user_tag_summary_ids = Enum.map(user_tag_summary_records, fn (user_tag_summary_record) -> user_tag_summary_record.id end)

    user_tag_summary_tag_records = Api.Repo.all(from utst in UserTagSummaryTag, where: utst.user_tag_summary_id in ^user_tag_summary_ids and utst.tag_id in ^tag_record_ids)
    user_tag_summary_user_records = Api.Repo.all(from utst in UserTagSummaryUser, where: utst.user_tag_summary_id in ^user_tag_summary_ids and utst.user_id in ^user_record_ids)

    multi = Multi.new
    |> Multi.update_all(:user_profile, Ecto.assoc(Api.Accounts.get_user!(attributes["user_id"]), :user_profile), inc: [post_count: 1])
    |> Multi.insert(:post, post_changeset)
    |> Multi.run(:timeline_item, fn %{post: post} ->
      Api.Repo.insert(Ecto.Changeset.change(timeline_item_changeset, %{post_id: post.id}))
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
      |> Multi.run("find_or_create_user_tag_summary_tag_#{tag}", fn %{aggregated_tag_records: aggregated_tag_records, timeline_item: timeline_item} ->
        tag_record = Enum.find(aggregated_tag_records, fn (tag_record) -> tag_record.name == tag end)
        user_tag_summary_tag_record = Enum.find(user_tag_summary_tag_records, fn (user_tag_summary_tag_record) ->
          user_tag_summary_tag_record.user_tag_summary_id == user_tag_summary_record.id && user_tag_summary_tag_record.tag_id == tag_record.id
        end)

        if (user_tag_summary_tag_record != nil) do
          Api.Repo.update(UserTagSummaryTag.changeset(user_tag_summary_tag_record, %{timeline_item_ids: [timeline_item.id | user_tag_summary_tag_record.timeline_item_ids]}))
        else
          Api.Repo.insert(UserTagSummaryTag.changeset(%UserTagSummaryTag{}, %{user_tag_summary_id: user_tag_summary_record.id, tag_id: tag_record.id, timeline_item_ids: [timeline_item.id]}))
        end
      end)
    end)
    Enum.reduce(user_records, multi, fn (user_record, multi) ->
      multi = multi
      |> Multi.run("find_or_create_user_tag_summary_user_#{user_record.username}", fn %{timeline_item: timeline_item} ->
        user_tag_summary_user_record = Enum.find(user_tag_summary_user_records, fn (user_tag_summary_user_record) ->
          user_tag_summary_user_record.user_tag_summary_id == user_tag_summary_record.id && user_tag_summary_user_record.user_id == user_record.id
        end)

        if (user_tag_summary_user_record != nil) do
          Api.Repo.update(UserTagSummaryUser.changeset(user_tag_summary_user_record, %{timeline_item_ids: [timeline_item.id | user_tag_summary_user_record.timeline_item_ids]}))
        else
          Api.Repo.insert(UserTagSummaryUser.changeset(%UserTagSummaryUser{}, %{user_tag_summary_id: user_tag_summary_record.id, user_id: user_record.id, timeline_item_ids: [timeline_item.id]}))
        end
      end)
      |> Multi.run("find_or_create_user_tag_summary_for_subject_#{user_record.username}", fn %{} ->
        user_tag_summary_record = Enum.find(user_tag_summary_records, fn (user_tag_summary_record) -> user_tag_summary_record.subject_id == user_record.id end)

        if (user_tag_summary_record != nil), do: {:ok, user_tag_summary_record}, else: Api.Repo.insert(UserTagSummary.changeset(%UserTagSummary{}, %{author_id: user.id, subject_id: user_record.id}))
      end)

      multi = Enum.reduce(tags, multi, fn (tag, multi) ->
        multi
        |> Multi.run("find_or_create_user_tag_summary_tag_#{tag}_about_user_#{user_record.username}", fn args ->
          user_tag_summary_record = args["find_or_create_user_tag_summary_for_subject_#{user_record.username}"]
          tag_record = Enum.find(args.aggregated_tag_records, fn (tag_record) -> tag_record.name == tag end)
          user_tag_summary_tag_record = Enum.find(user_tag_summary_tag_records, fn (user_tag_summary_tag_record) ->
            user_tag_summary_tag_record.user_tag_summary_id == user_tag_summary_record.id && user_tag_summary_tag_record.tag_id == tag_record.id
          end)

          if (user_tag_summary_tag_record != nil) do
            Api.Repo.update(UserTagSummaryTag.changeset(user_tag_summary_tag_record, %{timeline_item_ids: [args.timeline_item.id | user_tag_summary_tag_record.timeline_item_ids]}))
          else
            Api.Repo.insert(UserTagSummaryTag.changeset(%UserTagSummaryTag{}, %{user_tag_summary_id: user_tag_summary_record.id, tag_id: tag_record.id, timeline_item_ids: [args.timeline_item.id]}))
          end
        end)
      end)

      Enum.reduce(user_records, multi, fn (subuser_record, multi) ->
        if (user_record == subuser_record) do
          multi
        else
          multi
          |> Multi.run("find_or_create_user_tag_summary_user_#{user_record.username}_for_#{subuser_record.username}", fn args ->
            user_tag_summary_record = args["find_or_create_user_tag_summary_for_subject_#{user_record.username}"]
            user_tag_summary_user_record = Enum.find(user_tag_summary_user_records, fn (user_tag_summary_user_record) ->
              user_tag_summary_user_record.user_tag_summary_id == user_tag_summary_record.id && user_tag_summary_user_record.user_id == subuser_record.id
            end)

            if (user_tag_summary_user_record != nil) do
              Api.Repo.update(UserTagSummaryUser.changeset(user_tag_summary_user_record, %{timeline_item_ids: [args.timeline_item.id | user_tag_summary_user_record.timeline_item_ids]}))
            else
              Api.Repo.insert(UserTagSummaryUser.changeset(%UserTagSummaryUser{}, %{user_tag_summary_id: user_tag_summary_record.id, user_id: subuser_record.id, timeline_item_ids: [args.timeline_item.id]}))
            end
          end)
        end
      end)
    end)
    |> Multi.run(:user_tag_summary, fn %{timeline_item: timeline_item} ->
      if (timeline_item.private), do: Api.Repo.update(UserTagSummary.changeset(user_tag_summary_record, %{private_timeline_item_ids: [timeline_item.id | user_tag_summary_record.private_timeline_item_ids]})), else: {:ok, user_tag_summary_record}
    end)
    |> Multi.run(:libra, fn %{post: post} ->
      Libra.review(post, post.text)
    end)
  end

  def update(record, attributes) do
    post_changeset = Post.changeset(record, attributes)
    post_private_changeset = Post.private_changeset(record, %{ignore_flags: false})
    text_version_changeset = TextVersion.changeset(%TextVersion{}, %{
      text: record.text,
      attribute: "text",
      post_id: record.id
    })

    Multi.new
    |> Multi.update(:post, Ecto.Changeset.merge(post_changeset, post_private_changeset))
    |> Multi.run(:text_version, fn %{} ->
      if (Map.has_key?(post_changeset.changes, :text)), do: Api.Repo.insert(text_version_changeset), else: {:ok, record}
    end)
    |> Multi.run(:libra, fn %{post: post} ->
      Libra.review(post, post.text)
    end)
  end

  defp gather_tags(text, leading_char) do
    Enum.filter(Enum.uniq(List.flatten(Regex.scan(Regex.compile!("#{leading_char}([a-zA-Z0-9_]+)"), text))), fn (item) -> String.at(item, 0) != leading_char end)
  end
end
