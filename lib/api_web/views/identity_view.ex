defmodule ApiWeb.IdentityView do
  use ApiWeb, :view
  use JaSerializer.PhoenixView
  alias ApiWeb.{UserIdentityView}

  attributes [:name]

  has_many :user_identities,
    serializer: UserIdentityView
end
