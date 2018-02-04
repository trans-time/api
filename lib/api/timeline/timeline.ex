defmodule Api.Timeline do
  @moduledoc """
  The Timeline context.
  """

  import Ecto.Query, warn: false
  alias Api.Repo

  alias Api.Timeline.Tag

  @doc """
  Returns the list of tags.

  ## Examples

      iex> list_tags()
      [%Tag{}, ...]

  """
  def list_tags do
    Repo.all(Tag)
  end

  @doc """
  Gets a single tag.

  Raises `Ecto.NoResultsError` if the Tag does not exist.

  ## Examples

      iex> get_tag!(123)
      %Tag{}

      iex> get_tag!(456)
      ** (Ecto.NoResultsError)

  """
  def get_tag!(id), do: Repo.get!(Tag, id)

  @doc """
  Creates a tag.

  ## Examples

      iex> create_tag(%{field: value})
      {:ok, %Tag{}}

      iex> create_tag(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_tag(attrs \\ %{}) do
    %Tag{}
    |> Tag.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a tag.

  ## Examples

      iex> update_tag(tag, %{field: new_value})
      {:ok, %Tag{}}

      iex> update_tag(tag, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_tag(%Tag{} = tag, attrs) do
    tag
    |> Tag.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Tag.

  ## Examples

      iex> delete_tag(tag)
      {:ok, %Tag{}}

      iex> delete_tag(tag)
      {:error, %Ecto.Changeset{}}

  """
  def delete_tag(%Tag{} = tag) do
    Repo.delete(tag)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking tag changes.

  ## Examples

      iex> change_tag(tag)
      %Ecto.Changeset{source: %Tag{}}

  """
  def change_tag(%Tag{} = tag) do
    Tag.changeset(tag, %{})
  end

  alias Api.Timeline.TimelineItem

  @doc """
  Returns the list of timeline_items.

  ## Examples

      iex> list_timeline_items()
      [%TimelineItem{}, ...]

  """
  def list_timeline_items do
    Repo.all(TimelineItem)
  end

  @doc """
  Gets a single timeline_item.

  Raises `Ecto.NoResultsError` if the Timeline item does not exist.

  ## Examples

      iex> get_timeline_item!(123)
      %TimelineItem{}

      iex> get_timeline_item!(456)
      ** (Ecto.NoResultsError)

  """
  def get_timeline_item!(id), do: Repo.get!(TimelineItem, id)

  @doc """
  Creates a timeline_item.

  ## Examples

      iex> create_timeline_item(%{field: value})
      {:ok, %TimelineItem{}}

      iex> create_timeline_item(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_timeline_item(attrs \\ %{}) do
    %TimelineItem{}
    |> TimelineItem.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a timeline_item.

  ## Examples

      iex> update_timeline_item(timeline_item, %{field: new_value})
      {:ok, %TimelineItem{}}

      iex> update_timeline_item(timeline_item, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_timeline_item(%TimelineItem{} = timeline_item, attrs) do
    timeline_item
    |> TimelineItem.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a TimelineItem.

  ## Examples

      iex> delete_timeline_item(timeline_item)
      {:ok, %TimelineItem{}}

      iex> delete_timeline_item(timeline_item)
      {:error, %Ecto.Changeset{}}

  """
  def delete_timeline_item(%TimelineItem{} = timeline_item) do
    Repo.delete(timeline_item)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking timeline_item changes.

  ## Examples

      iex> change_timeline_item(timeline_item)
      %Ecto.Changeset{source: %TimelineItem{}}

  """
  def change_timeline_item(%TimelineItem{} = timeline_item) do
    TimelineItem.changeset(timeline_item, %{})
  end

  alias Api.Timeline.TimelineItemUser

  @doc """
  Returns the list of timeline_items_users.

  ## Examples

      iex> list_timeline_items_users()
      [%TimelineItemUser{}, ...]

  """
  def list_timeline_items_users do
    Repo.all(TimelineItemUser)
  end

  @doc """
  Gets a single timeline_item_user.

  Raises `Ecto.NoResultsError` if the Timeline item user does not exist.

  ## Examples

      iex> get_timeline_item_user!(123)
      %TimelineItemUser{}

      iex> get_timeline_item_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_timeline_item_user!(id), do: Repo.get!(TimelineItemUser, id)

  @doc """
  Creates a timeline_item_user.

  ## Examples

      iex> create_timeline_item_user(%{field: value})
      {:ok, %TimelineItemUser{}}

      iex> create_timeline_item_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_timeline_item_user(attrs \\ %{}) do
    %TimelineItemUser{}
    |> TimelineItemUser.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a timeline_item_user.

  ## Examples

      iex> update_timeline_item_user(timeline_item_user, %{field: new_value})
      {:ok, %TimelineItemUser{}}

      iex> update_timeline_item_user(timeline_item_user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_timeline_item_user(%TimelineItemUser{} = timeline_item_user, attrs) do
    timeline_item_user
    |> TimelineItemUser.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a TimelineItemUser.

  ## Examples

      iex> delete_timeline_item_user(timeline_item_user)
      {:ok, %TimelineItemUser{}}

      iex> delete_timeline_item_user(timeline_item_user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_timeline_item_user(%TimelineItemUser{} = timeline_item_user) do
    Repo.delete(timeline_item_user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking timeline_item_user changes.

  ## Examples

      iex> change_timeline_item_user(timeline_item_user)
      %Ecto.Changeset{source: %TimelineItemUser{}}

  """
  def change_timeline_item_user(%TimelineItemUser{} = timeline_item_user) do
    TimelineItemUser.changeset(timeline_item_user, %{})
  end
end
