defmodule ApiWeb.UserIdentityView do
  use JSONAPI.View, type: "user_identity"
  alias ApiWeb.{IdentityView, UserView}

  def fields do
    [:end_date, :start_date]
  end

  def relationships do
    [identity: IdentityView, user: UserView]
  end
end
