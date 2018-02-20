defmodule Api.Profile do
  @moduledoc """
  The Profile context.
  """

  import Ecto.Query, warn: false
  alias Api.Repo

  alias Api.Profile.UserProfile

  @doc """
  Returns the list of user_profiles.

  ## Examples

      iex> list_user_profiles()
      [%UserProfile{}, ...]

  """
  def list_user_profiles do
    Repo.all(UserProfile)
  end

  @doc """
  Gets a single user_profile.

  Raises `Ecto.NoResultsError` if the User profile does not exist.

  ## Examples

      iex> get_user_profile!(123)
      %UserProfile{}

      iex> get_user_profile!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user_profile!(id), do: Repo.get!(UserProfile, id)

  @doc """
  Creates a user_profile.

  ## Examples

      iex> create_user_profile(%{field: value})
      {:ok, %UserProfile{}}

      iex> create_user_profile(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user_profile(attrs \\ %{}) do
    %UserProfile{}
    |> UserProfile.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user_profile.

  ## Examples

      iex> update_user_profile(user_profile, %{field: new_value})
      {:ok, %UserProfile{}}

      iex> update_user_profile(user_profile, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user_profile(%UserProfile{} = user_profile, attrs) do
    user_profile
    |> UserProfile.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a UserProfile.

  ## Examples

      iex> delete_user_profile(user_profile)
      {:ok, %UserProfile{}}

      iex> delete_user_profile(user_profile)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user_profile(%UserProfile{} = user_profile) do
    Repo.delete(user_profile)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user_profile changes.

  ## Examples

      iex> change_user_profile(user_profile)
      %Ecto.Changeset{source: %UserProfile{}}

  """
  def change_user_profile(%UserProfile{} = user_profile) do
    UserProfile.changeset(user_profile, %{})
  end

  alias Api.Profile.UserTagSummary

  @doc """
  Returns the list of user_tag_summaries.

  ## Examples

      iex> list_user_tag_summaries()
      [%UserTagSummary{}, ...]

  """
  def list_user_tag_summaries do
    Repo.all(UserTagSummary)
  end

  @doc """
  Gets a single user_tag_summary.

  Raises `Ecto.NoResultsError` if the User tag summary does not exist.

  ## Examples

      iex> get_user_tag_summary!(123)
      %UserTagSummary{}

      iex> get_user_tag_summary!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user_tag_summary!(id), do: Repo.get!(UserTagSummary, id)

  @doc """
  Creates a user_tag_summary.

  ## Examples

      iex> create_user_tag_summary(%{field: value})
      {:ok, %UserTagSummary{}}

      iex> create_user_tag_summary(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user_tag_summary(attrs \\ %{}) do
    %UserTagSummary{}
    |> UserTagSummary.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user_tag_summary.

  ## Examples

      iex> update_user_tag_summary(user_tag_summary, %{field: new_value})
      {:ok, %UserTagSummary{}}

      iex> update_user_tag_summary(user_tag_summary, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user_tag_summary(%UserTagSummary{} = user_tag_summary, attrs) do
    user_tag_summary
    |> UserTagSummary.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a UserTagSummary.

  ## Examples

      iex> delete_user_tag_summary(user_tag_summary)
      {:ok, %UserTagSummary{}}

      iex> delete_user_tag_summary(user_tag_summary)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user_tag_summary(%UserTagSummary{} = user_tag_summary) do
    Repo.delete(user_tag_summary)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user_tag_summary changes.

  ## Examples

      iex> change_user_tag_summary(user_tag_summary)
      %Ecto.Changeset{source: %UserTagSummary{}}

  """
  def change_user_tag_summary(%UserTagSummary{} = user_tag_summary) do
    UserTagSummary.changeset(user_tag_summary, %{})
  end

  alias Api.Profile.Identity

  @doc """
  Returns the list of identities.

  ## Examples

      iex> list_identities()
      [%Identity{}, ...]

  """
  def list_identities do
    Repo.all(Identity)
  end

  @doc """
  Gets a single identity.

  Raises `Ecto.NoResultsError` if the Identity does not exist.

  ## Examples

      iex> get_identity!(123)
      %Identity{}

      iex> get_identity!(456)
      ** (Ecto.NoResultsError)

  """
  def get_identity!(id), do: Repo.get!(Identity, id)

  @doc """
  Creates a identity.

  ## Examples

      iex> create_identity(%{field: value})
      {:ok, %Identity{}}

      iex> create_identity(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_identity(attrs \\ %{}) do
    %Identity{}
    |> Identity.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a identity.

  ## Examples

      iex> update_identity(identity, %{field: new_value})
      {:ok, %Identity{}}

      iex> update_identity(identity, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_identity(%Identity{} = identity, attrs) do
    identity
    |> Identity.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Identity.

  ## Examples

      iex> delete_identity(identity)
      {:ok, %Identity{}}

      iex> delete_identity(identity)
      {:error, %Ecto.Changeset{}}

  """
  def delete_identity(%Identity{} = identity) do
    Repo.delete(identity)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking identity changes.

  ## Examples

      iex> change_identity(identity)
      %Ecto.Changeset{source: %Identity{}}

  """
  def change_identity(%Identity{} = identity) do
    Identity.changeset(identity, %{})
  end

  alias Api.Profile.UserIdentity

  @doc """
  Returns the list of user_identities.

  ## Examples

      iex> list_user_identities()
      [%UserIdentity{}, ...]

  """
  def list_user_identities do
    Repo.all(UserIdentity)
  end

  @doc """
  Gets a single user_identity.

  Raises `Ecto.NoResultsError` if the User identity does not exist.

  ## Examples

      iex> get_user_identity!(123)
      %UserIdentity{}

      iex> get_user_identity!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user_identity!(id), do: Repo.get!(UserIdentity, id)

  @doc """
  Creates a user_identity.

  ## Examples

      iex> create_user_identity(%{field: value})
      {:ok, %UserIdentity{}}

      iex> create_user_identity(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user_identity(attrs \\ %{}) do
    %UserIdentity{}
    |> UserIdentity.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user_identity.

  ## Examples

      iex> update_user_identity(user_identity, %{field: new_value})
      {:ok, %UserIdentity{}}

      iex> update_user_identity(user_identity, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user_identity(%UserIdentity{} = user_identity, attrs) do
    user_identity
    |> UserIdentity.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a UserIdentity.

  ## Examples

      iex> delete_user_identity(user_identity)
      {:ok, %UserIdentity{}}

      iex> delete_user_identity(user_identity)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user_identity(%UserIdentity{} = user_identity) do
    Repo.delete(user_identity)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user_identity changes.

  ## Examples

      iex> change_user_identity(user_identity)
      %Ecto.Changeset{source: %UserIdentity{}}

  """
  def change_user_identity(%UserIdentity{} = user_identity) do
    UserIdentity.changeset(user_identity, %{})
  end
end
