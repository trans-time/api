import Ecto.Query

defmodule ApiWeb.Services.MailManager do
  alias Api.Accounts.{CurrentUser, User, UserPassword}
  alias Api.Mail.MailSubscriptionToken
  alias Api.Profile.{UserProfile, UserTagSummary}
  alias ApiWeb.Services.{FollowManager, SubscriptionManager}
  alias Ecto.Multi

  def send(user, args, email) do
    Multi.new
    |> Multi.insert(:mail_subscription_token, MailSubscriptionToken.changeset(%MailSubscriptionToken{}, %{
      user_id: user.id
    }))
    |> Multi.run(:mail, fn %{mail_subscription_token: mail_subscription_token} ->
      apply(Api.Mail.Email, email, [user, mail_subscription_token, args])
      |> Api.Mail.Mailer.deliver_later()

      {:ok, user}
    end)
  end
end
