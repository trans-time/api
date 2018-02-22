# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Api.Repo.insert!(%Api.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
import Api.Factory
import Ecto.Query
tags = insert_list(12, :tag)
celeste = insert(:user, %{username: "celeste", email: "celeste@trans.time"})
other_users = insert_list(5, :user)
timeline_items = []

timeline_items = for _ <- 1..30, do: insert(:timeline_item, %{user: celeste, tags: Enum.take_random(tags, 3), users: Enum.take_random(other_users, 2), post: insert(:post), private: Enum.random([true, false])})
for _ <- 1..30, do: insert(:timeline_item, %{user: Enum.random(other_users), tags: Enum.take_random(tags, 3), users: Enum.take_random(other_users, 2), post: insert(:post), private: Enum.random([true, false])})

summary = Enum.reduce(timeline_items, Map.put(%{}, celeste.id, %{tags: %{}, users: %{}, private: []}), fn(item, summary) ->
  Map.put(%{}, celeste.id, %{tags: Enum.reduce(item.tags, summary[celeste.id].tags, fn(tag, tags) ->
    if Map.has_key?(tags, tag.id) do
      Map.put(tags, tag.id, tags[tag.id] ++ [item.id])
    else
      Map.put(tags, tag.id, [item.id])
    end
  end), users: Enum.reduce(item.users, summary[celeste.id].users, fn(user, users) ->
    if Map.has_key?(users, user.id) do
      Map.put(users, user.id, users[user.id] ++ [item.id])
    else
      Map.put(users, user.id, [item.id])
    end
  end), private: (if (item.private), do: [item.id | summary[celeste.id].private], else: summary[celeste.id].private)})
end)
summary_tag_ids = Map.keys(summary[celeste.id].tags)
summary_user_ids = Map.keys(summary[celeste.id].users)

Enum.each(Api.Repo.all(Api.Timeline.Post), fn(post) ->
  Enum.each(other_users, fn(user) ->
    insert(:reaction, %{user: user, post: post, type: Enum.random([1, 2, 3])})

    parent = insert(:comment, %{user: Enum.random(other_users), post: post})
    insert(:comment, %{user: Enum.random(other_users), parent: parent, post: post})
  end)
end)

Api.Repo.preload(celeste.user_profile.user_tag_summary, [:tags, :users]) |> Ecto.Changeset.change(%{
  summary: summary
}) |> Ecto.Changeset.put_assoc(:tags, Api.Timeline.Tag |> where([p], p.id in ^summary_tag_ids) |> Api.Repo.all) |> Ecto.Changeset.put_assoc(:users, Api.Accounts.User |> where([p], p.id in ^summary_user_ids) |> Api.Repo.all) |> Api.Repo.update!

Enum.each(other_users, fn(user) ->
  insert(:follow, %{followed: user, follower: celeste})
  insert(:follow, %{followed: celeste, follower: user})
end)
