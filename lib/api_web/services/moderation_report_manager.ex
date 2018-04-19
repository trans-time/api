import Ecto.Query

defmodule ApiWeb.Services.ModerationReportManager do
  alias Ecto.Multi
  alias Api.Moderation.ModerationReport

  def update(record, attributes) do
    changeset = ModerationReport.changeset(record, attributes)

    Multi.new
    |> Multi.update(:moderation_report, changeset)
  end
end
