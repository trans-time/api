import Ecto.Query

defmodule Api.Accounts.UserPassword do
  use Api.Schema
  import Ecto.Changeset
  alias Api.Accounts.{User, UserPassword}


  schema "user_passwords" do
    field :password, :string

    belongs_to :user, User
  end

  @doc false
  def public_insert_changeset(%UserPassword{} = user_password, attrs) do
    user_password
    |> cast(attrs, [:user_id])
    |> unique_constraint(:user_id)
    |> assoc_constraint(:user)
    |> public_shared_changeset(attrs)
  end

  @doc false
  def public_update_changeset(%UserPassword{} = user_password, attrs) do
    user_password
    |> public_shared_changeset(attrs)
  end

  @doc false
  defp public_shared_changeset(user_password, attrs) do
    user_password
    |> cast(attrs, [:password])
    |> validate_required([:password])
    |> validate_length(:password, max: 1000, message: "remote.errors.detail.length.length")
    |> put_pass_hash()
  end

  defp put_pass_hash(%Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset) do
    change(changeset, %{ password: Comeonin.Argon2.hashpwsalt(password) })
  end
  defp put_pass_hash(changeset), do: changeset
end
