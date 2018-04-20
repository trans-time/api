import Ecto.Query

defmodule ApiWeb.VerdictController do
  use ApiWeb, :controller
  use JaResource # Optionally put in web/web.ex
  plug JaResource

  alias Api.Moderation.Verdict
  alias ApiWeb.Services.VerdictManager

  def model, do: Verdict

  def handle_create(conn, attributes) do
    handle_request(conn, VerdictManager.insert(attributes))
  end

  defp handle_request(conn, multi) do
    transaction = Api.Repo.transaction(multi)
    if Kernel.elem(transaction, 0) === :ok, do: Kernel.elem(transaction, 1).verdict, else: transaction
  end
end
