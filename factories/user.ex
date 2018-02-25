defmodule Api.Factory do
  # with Ecto
  use ExMachina.Ecto, repo: Api.Repo

  def tag_factory do
    %Api.Timeline.Tag{
      name: Faker.Superhero.power
    }
  end

  def reaction_factory do
    %Api.Timeline.Reaction{
      type: Enum.random([1, 2, 3])
    }
  end

  def timeline_item_factory do
    %Api.Timeline.TimelineItem{
      date: Faker.DateTime.backward(4)
    }
  end

  def comment_factory do
    %Api.Timeline.Comment{
      text: Faker.Lorem.Shakespeare.hamlet
    }
  end

  def post_factory do
    %Api.Timeline.Post{
      text: Faker.Lorem.Shakespeare.hamlet,
      images: insert_list(4, :image)
    }
  end

  def image_factory do
    %Api.Timeline.Image{
      src: Faker.Internet.image_url,
      order: 1
    }
  end

  def follow_factory do
    %Api.Relationship.Follow{
      can_view_private: Enum.random([true, false]),
      requested_private: false
    }
  end

  def user_factory do
    %Api.Accounts.User{
      avatar: Faker.Avatar.image_url(200, 200),
      email: Faker.Internet.email,
      display_name: Faker.Pokemon.name,
      is_moderator: true,
      password: Comeonin.Argon2.hashpwsalt("asdfasdf"),
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
