import Ecto.Query

defmodule ApiWeb.Services.UserIdentityManager do
  alias Api.Profile.{Identity, UserIdentity}
  alias Ecto.Multi

  def delete(record) do
    Multi.new
    |> Multi.delete(:user_identity, record)
    |> Multi.update_all(:identity_count, Identity |> where([i], i.id == ^record.identity_id), inc: [user_identity_count: -1])
  end

  def insert(attributes) do
    identity_name = attributes["name"]
    identity = Api.Repo.get_by(Identity, %{name: identity_name})

    handle_insert_and_update(UserIdentity.public_insert_changeset(%UserIdentity{}, attributes), identity, identity_name)
  end

  def update(record, attributes) do
    identity_name = attributes["name"]
    previous_identity = Api.Repo.get(Identity, record.identity_id)

    if (previous_identity.name !== identity_name), do: identity = Api.Repo.get_by(Identity, %{name: identity_name}), else: identity = previous_identity

    handle_insert_and_update(UserIdentity.public_update_changeset(record, attributes), identity, identity_name, previous_identity)
  end

  defp handle_insert_and_update(changeset, identity, identity_name, previous_identity \\ nil) do
    Multi.new
    |> Multi.run(:identity, fn _ ->
      if identity, do: {:ok, identity}, else: Api.Repo.insert(Identity.changeset(%Identity{}, %{name: identity_name}))
    end)
    |> Multi.run(:user_identity, fn %{identity: identity} ->
      Api.Repo.insert_or_update(Ecto.Changeset.change(changeset, %{identity_id: identity.id}))
    end)
    |> Multi.merge(fn %{user_identity: user_identity} ->
      Multi.new
      |> Multi.update_all(:identity_count, Identity |> where([i], i.id == ^user_identity.identity_id), inc: [user_identity_count: 1])
    end)
    |> Multi.append(
      if (previous_identity) do
        Multi.new
        |> Multi.update_all(:previous_identity_count, Identity |> where([i], i.id == ^previous_identity.id), inc: [user_identity_count: -1])
      else
        Multi.new
      end
    )
  end
end
