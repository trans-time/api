defmodule ApiWeb.AuthController do
  use ApiWeb, :controller
  plug Ueberauth

  alias Api.Accounts.Guardian
  alias Api.Accounts.User
  alias Api.Mail.MailUnlockToken
  alias ApiWeb.Services.MailManager
  alias Ecto.Multi

  def delete(conn, _params) do
    # Sign out the user
    conn
    |> put_status(200)
    |> Guardian.Plug.sign_out(conn)
  end

  def identity_callback(conn, %{"data" => %{ "attributes" => attributes }}) do
    case Recaptcha.verify(attributes["re_captcha_response"]) do
      {:ok, response} ->
        case User.get_user_by_identification(Map.get(attributes, "identification")) do
          nil -> invalid_identity(conn)
          user ->
            case user.is_locked do
              true -> account_locked(conn)
              _ ->
                if User.validate_password(user, Map.get(attributes, "password")) do
                  {:ok, _, _} = Guardian.encode_and_sign(user)
                  auth_conn = Guardian.Plug.sign_in(conn, user)
                  jwt = Guardian.Plug.current_token(auth_conn)
                  Api.Repo.update(User.private_changeset(user, %{
                    consecutive_failed_logins: 0
                  }))
                  auth_conn
                  |> put_resp_header("authorization", "Bearer #{jwt}")
                  |> json(%{token: jwt, username: user.username}) # Return token to the client
                else
                  consecutive_failed_logins = user.consecutive_failed_logins + 1

                  multi = Multi.new
                  |> Multi.update(:user, User.private_changeset(user, %{
                    consecutive_failed_logins: consecutive_failed_logins,
                    is_locked: (if (consecutive_failed_logins > 5), do: true, else: false)
                  }))
                  |> Multi.run(:mail_unlock_token, fn args ->
                    if (args.user.is_locked) do
                      Api.Repo.insert(MailUnlockToken.changeset(%MailUnlockToken{}, %{
                        user_id: user.id
                      }))
                    else
                      {:ok, user}
                    end
                  end)
                  |> Multi.merge(fn args ->
                    if (args.user.is_locked) do
                      MailManager.send(args.user, args, :account_locked)
                    else
                      Multi.new
                    end
                  end)

                  Api.Repo.transaction(multi)

                  invalid_identity(conn)
                end
            end
        end
      {:error, errors} -> invalid_recaptcha(conn)
    end
  end

  defp account_locked(conn) do
    conn
    |> put_status(403)
    |> json(%{errors: [%{title: "remote.errors.title.forbidden", detail: "remote.errors.detail.forbidden.accountLocked", status: "403"}]})
  end

  defp invalid_recaptcha(conn) do
    conn
    |> put_status(401)
    |> json(%{errors: [%{title: "remote.errors.title.invalid", detail: "remote.errors.detail.invalid.recaptcha", status: "401"}]})
  end

  defp invalid_identity(conn) do
    conn
    |> put_status(401)
    |> json(%{errors: [%{title: "remote.errors.title.invalid", detail: "remote.errors.detail.invalid.usernameOrPassword", status: "401"}]})
  end
end
