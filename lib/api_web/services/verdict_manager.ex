import Ecto.Query

defmodule ApiWeb.Services.VerdictManager do
  alias Ecto.Multi
  alias Api.Moderation.{ModerationReport, Verdict}

  def insert(attributes) do
    IO.inspect(attributes)
    moderation_report = Api.Repo.get(ModerationReport, attributes["moderation_report_id"])
    verdict_changeset = Verdict.changeset(%Verdict{}, attributes)
    moderation_report_changeset = ModerationReport.changeset(moderation_report, %{
      resolved: true,
      was_violation: attributes["was_violation"]
    })

    Multi.new
    |> Multi.update(:moderation_report, moderation_report_changeset)
    |> Multi.insert(:verdict, verdict_changeset)
  end
end
