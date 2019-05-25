import Ecto.Query

defmodule ApiWeb.Services.UserProfileManager do
  alias Api.Accounts.User
  alias Api.Profile.{Identity, UserProfile, UserTagSummary}
  alias Api.Timeline.{Post, TimelineItem}
  alias Ecto.Multi

  def update(record, attributes) do
    user = Api.Repo.get(User, record.user_id)
    user_attributes = Map.take(attributes, ["avatar", "display_name", "pronouns", "username"])
    user_changeset = User.public_update_changeset(user, user_attributes)
    user_profile_changeset = UserProfile.changeset(record, attributes)

    multi = Multi.new
    |> Multi.update(:user, user_changeset)
    |> Multi.update(:user_profile, user_profile_changeset)

    if (Ecto.Changeset.get_change(user_changeset, :username)) do
      user_tag_summaries = Api.Repo.all(
        UserTagSummary
        |> where(subject_id: ^record.user_id)
        |> preload(:user_tag_summary_users)
      )
      aggregated_timeline_item_ids = Enum.uniq(Enum.flat_map(user_tag_summaries, fn (uts) ->
        Enum.flat_map(uts.user_tag_summary_users, fn (utsu) ->
          utsu.timeline_item_ids
        end)
      end))
      timeline_items = Api.Repo.all(
        TimelineItem
        |> where([ti], ti.id in ^aggregated_timeline_item_ids)
        |> preload(:post)
      )
      posts = Enum.uniq(Enum.reduce(timeline_items, [], fn (ti, acc) ->
        if (is_nil(ti.post)), do: acc, else: [ti.post | acc]
      end))
      pattern = Regex.compile!("@#{user.username}(?![a-zA-Z0-9_]+)")

      Enum.reduce(posts, multi, fn(post, multi) ->
        text = String.replace(post.text, pattern, "@#{user_attributes["username"]}")
        post_changeset = Post.changeset(post, %{ text: text })

        Multi.new
        |> Multi.update("update_post_#{post.id}", post_changeset)
        |> Multi.prepend(multi)
      end)
    else
      multi
    end
  end
end
