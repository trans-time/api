defmodule Api.Factory do
  # with Ecto
  use ExMachina.Ecto, repo: Api.Repo

  def user_factory do
    %Api.Accounts.User{
      avatar: "https://s3.amazonaws.com/uifaces/faces/twitter/carlyson/128.jpg",
      display_name: "foo bar :sunglasses:",
      is_moderator: true,
      pronouns: "she/her",
      username: "foo_bar"
    }
  end
end
