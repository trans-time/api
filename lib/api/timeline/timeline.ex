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

  alias Api.Timeline.Post

  @doc """
  Returns the list of posts.

  ## Examples

      iex> list_posts()
      [%Post{}, ...]

  """
  def list_posts do
    Repo.all(Post)
  end

  @doc """
  Gets a single post.

  Raises `Ecto.NoResultsError` if the Post does not exist.

  ## Examples

      iex> get_post!(123)
      %Post{}

      iex> get_post!(456)
      ** (Ecto.NoResultsError)

  """
  def get_post!(id), do: Repo.get!(Post, id)

  @doc """
  Creates a post.

  ## Examples

      iex> create_post(%{field: value})
      {:ok, %Post{}}

      iex> create_post(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_post(attrs \\ %{}) do
    %Post{}
    |> Post.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a post.

  ## Examples

      iex> update_post(post, %{field: new_value})
      {:ok, %Post{}}

      iex> update_post(post, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_post(%Post{} = post, attrs) do
    post
    |> Post.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Post.

  ## Examples

      iex> delete_post(post)
      {:ok, %Post{}}

      iex> delete_post(post)
      {:error, %Ecto.Changeset{}}

  """
  def delete_post(%Post{} = post) do
    Repo.delete(post)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking post changes.

  ## Examples

      iex> change_post(post)
      %Ecto.Changeset{source: %Post{}}

  """
  def change_post(%Post{} = post) do
    Post.changeset(post, %{})
  end

  alias Api.Timeline.Reaction

  @doc """
  Returns the list of reactions.

  ## Examples

      iex> list_reactions()
      [%Reaction{}, ...]

  """
  def list_reactions do
    Repo.all(Reaction)
  end

  @doc """
  Gets a single reaction.

  Raises `Ecto.NoResultsError` if the Reaction does not exist.

  ## Examples

      iex> get_reaction!(123)
      %Reaction{}

      iex> get_reaction!(456)
      ** (Ecto.NoResultsError)

  """
  def get_reaction!(id), do: Repo.get!(Reaction, id)

  @doc """
  Creates a reaction.

  ## Examples

      iex> create_reaction(%{field: value})
      {:ok, %Reaction{}}

      iex> create_reaction(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_reaction(attrs \\ %{}) do
    %Reaction{}
    |> Reaction.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a reaction.

  ## Examples

      iex> update_reaction(reaction, %{field: new_value})
      {:ok, %Reaction{}}

      iex> update_reaction(reaction, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_reaction(%Reaction{} = reaction, attrs) do
    reaction
    |> Reaction.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Reaction.

  ## Examples

      iex> delete_reaction(reaction)
      {:ok, %Reaction{}}

      iex> delete_reaction(reaction)
      {:error, %Ecto.Changeset{}}

  """
  def delete_reaction(%Reaction{} = reaction) do
    Repo.delete(reaction)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking reaction changes.

  ## Examples

      iex> change_reaction(reaction)
      %Ecto.Changeset{source: %Reaction{}}

  """
  def change_reaction(%Reaction{} = reaction) do
    Reaction.changeset(reaction, %{})
  end
end
