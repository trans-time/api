import Ecto.Query

defmodule ApiWeb.VerdictController do
  use ApiWeb, :controller
  use JaResource # Optionally put in web/web.ex
  plug JaResource

  alias Api.Accounts.User
  alias Api.Moderation.Verdict
  alias ApiWeb.Services.VerdictManager

  def model, do: Verdict

  def handle_create(conn, attributes) do
    handle_request(conn, VerdictManager.insert(attributes))
  end

  defp handle_request(conn, multi) do
    # current_user = Api.Repo.get(User, String.to_integer(Api.Accounts.Guardian.Plug.current_claims(conn)["sub"] || "-1"))
    #
    # if current_user.is_moderator do
      transaction = Api.Repo.transaction(multi)
      if Kernel.elem(transaction, 0) === :ok, do: Kernel.elem(transaction, 1).verdict, else: transaction
    # else
    #   {:error, [%{status: "403", source: %{pointer: "/data/relationships/user/data/isModerator"}, title: "remote.errors.title.forbidden", detail: "remote.errors.detail.forbidden.mustBeModerator"}]}
    # end
  end
end
