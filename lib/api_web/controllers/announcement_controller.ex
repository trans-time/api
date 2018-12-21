import Ecto.Query

defmodule ApiWeb.AnnouncementController do
  alias Api.Accounts.User
  alias Api.Mail.{Subscription, SubscriptionType}
  alias ApiWeb.Services.MailManager
  alias Ecto.Multi

  use ApiWeb, :controller

  def create(conn, %{"data" => data}) do
    attrs = JaSerializer.Params.to_attributes(data)
    options = %{
      subject: attrs["subject"],
      body: Kernel.elem(Earmark.as_html(attrs["body"]), 1)
    }
    announcementSubscriptionType = Api.Repo.get_by(SubscriptionType, name: "announcements")
    users = Api.Repo.all(from(u in User,
      join: s in Subscription,
      where: s.user_id == u.id
        and s.subscription_type_id == ^announcementSubscriptionType.id,
      group_by: [u.id]
    ))

    Enum.each(users, fn user ->
      multi = Multi.new
      |> Multi.merge(fn _ ->
        MailManager.send(user, options, :announcement)
      end)

      Api.Repo.transaction(multi)
    end)

    conn
  end
end
