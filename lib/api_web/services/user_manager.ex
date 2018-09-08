import Ecto.Query

defmodule ApiWeb.Services.UserManager do
  alias Api.Accounts.{CurrentUser, User, UserPassword}
  alias Api.Mail.MailConfirmationToken
  alias Api.Profile.{UserProfile, UserTagSummary}
  alias ApiWeb.Services.{FollowManager, MailManager, SubscriptionManager}
  alias Ecto.Multi

  def insert_user(attributes) do
    changeset = User.public_insert_changeset(%User{
      current_user: %CurrentUser{},
      user_profile: %UserProfile{}
    }, attributes)

    Multi.new
    |> Multi.insert(:user, changeset)
    |> Multi.run(:user_password, fn %{user: user} ->
      Api.Repo.insert(UserPassword.public_insert_changeset(%UserPassword{
        user: user
      }, attributes))
    end)
    |> Multi.run(:user_tag_summary, fn %{user: user} ->
      Api.Repo.insert(UserTagSummary.changeset(%UserTagSummary{}, %{
        author_id: user.id,
        subject_id: user.id
      }))
    end)
    |> Multi.merge(fn %{user: user} ->
      FollowManager.insert(%{
        "followed_id" => Api.Repo.get_by!(Api.Accounts.User, username: "celeste").id,
        "follower_id" => user.id
      })
    end)
    |> Multi.merge(fn %{user: user} ->
      SubscriptionManager.subscribe_to_all(["announcements", "notifications"], user)
    end)
    |> Multi.run(:mail_confirmation_token, fn %{user: user} ->
      Api.Repo.insert(MailConfirmationToken.changeset(%MailConfirmationToken{}, %{
        user_id: user.id
      }))
    end)
    |> Multi.merge(fn args ->
      MailManager.send(args.user, args, :welcome)
    end)
  end
end
