defmodule Api.Factory do
  # with Ecto
  use ExMachina.Ecto, repo: Api.Repo

  def tag_factory do
    %Api.Timeline.Tag{
      name: Faker.Superhero.power
    }
  end

  def timeline_item_factory do
    %Api.Timeline.TimelineItem{
      date: Faker.DateTime.backward(4)
    }
  end

  def user_factory do
    %Api.Accounts.User{
      avatar: Faker.Avatar.image_url(200, 200),
      display_name: Faker.Pokemon.name,
      is_moderator: true,
      pronouns: Enum.random(["she/her", "he/him", "they/them", "she/her; they/them", "he/him; they/them"]),
      username: Faker.Pokemon.name,
      user_profile: insert(:user_profile),
      user_identities: insert_list(4, :user_identity)
    }
  end

  def user_profile_factory do
    %Api.Profile.UserProfile{
      description: Faker.Lorem.Shakespeare.hamlet,
      total_posts: 7,
      website: Faker.Internet.url,
      user_tag_summary: insert(:user_tag_summary)
    }
  end

  def user_tag_summary_factory do
    %Api.Profile.UserTagSummary{
      summary: %{}
    }
  end

  def identity_factory do
    %Api.Profile.Identity{
      name: Faker.Pokemon.name
    }
  end

  def user_identity_factory do
    %Api.Profile.UserIdentity{
      identity: insert(:identity),
      start_date: Faker.DateTime.backward(4),
      end_date: Faker.DateTime.backward(4)
    }
  end
end
