defmodule ApiWeb.CommentView do
  use ApiWeb, :view
  use JaSerializer.PhoenixView
  alias ApiWeb.{CommentView, UserView}

  def type(_post,_conn), do: "comment"

  attributes [:inserted_at, :deleted, :text]

  has_one :user,
    serializer: UserView,
    include: false

  has_one :parent,
    serializer: CommentView,
    include: false

  has_many :children,
    serializer: CommentView,
    include: false

  def user(%{user: %Ecto.Association.NotLoaded{}, user_id: nil}, _conn), do: nil
  def user(%{user: %Ecto.Association.NotLoaded{}, user_id: id}, _conn), do: %{id: id}
  def user(%{user: user}, _conn), do: user

  def parent(%{parent: %Ecto.Association.NotLoaded{}, parent_id: nil}, _conn), do: nil
  def parent(%{parent: %Ecto.Association.NotLoaded{}, parent_id: id}, _conn), do: %{id: id}
  def parent(%{parent: parent}, _conn), do: parent

  def preload(record_or_records, _conn, include_opts) do
    Api.Repo.preload(record_or_records, include_opts)
  end
end
