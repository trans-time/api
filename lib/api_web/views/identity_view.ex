defmodule ApiWeb.IdentityView do
  use JSONAPI.View, type: "identity"
  alias ApiWeb.{UserIdentityView}

  def fields do
    [:name]
  end

  def relationships do
    [userIdentities: UserIdentityView]
  end
end
