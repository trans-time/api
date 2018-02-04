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
celeste = insert(:user, %{username: "celeste"})
other_users = insert_list(5, :user)
timeline_items = []

timeline_items = for _ <- 1..10, do: insert(:timeline_item, %{user: celeste, tags: Enum.take_random(tags, 3), users: Enum.take_random(other_users, 2)})
summary = Enum.reduce(timeline_items, %{celeste: %{tags: %{}, users: %{}}}, fn(item, summary) ->
  %{ celeste: %{tags: Enum.reduce(item.tags, summary.celeste.tags, fn(tag, tags) ->
    if Map.has_key?(tags, tag.id) do
      Map.put(tags, tag.id, tags[tag.id] ++ [item.id])
    else
      Map.put(tags, tag.id, [item.id])
    end
  end), users: Enum.reduce(item.users, summary.celeste.users, fn(user, users) ->
    if Map.has_key?(users, user.id) do
      Map.put(users, user.id, users[user.id] ++ [item.id])
    else
      Map.put(users, user.id, [item.id])
    end
  end)}}
end)
summary_tag_ids = Map.keys(summary.celeste.tags)
summary_user_ids = Map.keys(summary.celeste.users)

Api.Repo.preload(celeste.user_profile.user_tag_summary, [:tags, :users]) |> Ecto.Changeset.change(%{
  summary: summary
}) |> Ecto.Changeset.put_assoc(:tags, Api.Timeline.Tag |> where([p], p.id in ^summary_tag_ids) |> Api.Repo.all) |> Ecto.Changeset.put_assoc(:users, Api.Accounts.User |> where([p], p.id in ^summary_user_ids) |> Api.Repo.all) |> Api.Repo.update!
