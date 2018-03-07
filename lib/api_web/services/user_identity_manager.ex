import Ecto.Query

defmodule ApiWeb.Services.UserIdentityManager do
  alias Api.Profile.{Identity, UserIdentity}
  alias Ecto.Multi

  def delete(record) do
    Multi.new
    |> Multi.delete(:user_identity, record)
  end

  def insert(attributes) do
    identity_name = attributes["name"]
    identity = Api.Repo.get_by(Identity, %{name: identity_name})

    handle_insert_and_update(UserIdentity.changeset(%UserIdentity{}, attributes), identity, identity_name)
  end

  def update(record, attributes) do
    identity_name = attributes["name"]
    identity = Api.Repo.get(Identity, record.identity_id)

    if (identity.name !== identity_name), do: identity = Api.Repo.get_by(Identity, %{name: identity_name})

    handle_insert_and_update(UserIdentity.changeset(record, attributes), identity, identity_name)
  end

  defp handle_insert_and_update(changeset, identity, identity_name) do
    if identity do
      insert_or_update_user_identity(changeset, identity.id)
    else
      insert_identity_and_insert_or_update_user_identity(changeset, identity_name)
    end
  end

  defp insert_identity_and_insert_or_update_user_identity(changeset, identity_name) do
    Multi.new
    |> Multi.insert(:identity, Identity.changeset(%Identity{}, %{name: identity_name}))
    |> Multi.run(:user_identity, fn %{identity: identity} ->
      Api.Repo.insert_or_update(Ecto.Changeset.change(changeset, %{identity_id: identity.id}))
    end)
  end

  defp insert_or_update_user_identity(changeset, identity_id) do
    Multi.new
    |> Multi.insert_or_update(:user_identity, Ecto.Changeset.change(changeset, %{identity_id: identity_id}))
  end
end
