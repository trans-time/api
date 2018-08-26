import Ecto.Query

defmodule ApiWeb.Services.ContentWarningManager do
  alias Api.Timeline.{ContentWarning}
  alias Ecto.Multi

  def insert(timeline_item, content_warnings) do
    content_warning_records = Api.Repo.all(from cw in ContentWarning, where: cw.name in ^content_warnings)
    content_warning_record_ids = Enum.map(content_warning_records, fn (cw) -> cw.id end)
    multi = Multi.new
    Enum.reduce(content_warnings, multi, fn (content_warning, multi) ->
      multi
      |> Multi.run("find_or_create_content_warning_#{content_warning}", fn %{} ->
        content_warning_record = Enum.find(content_warning_records, fn (content_warning_record) -> content_warning_record.name == content_warning end)

        if (content_warning_record != nil), do: {:ok, content_warning_record}, else: Api.Repo.insert(ContentWarning.changeset(%ContentWarning{}, %{name: content_warning}))
      end)
    end)
    |> Multi.run(:aggregated_content_warning_records, fn args ->
      {:ok, Enum.map(content_warnings, fn (cw) -> args["find_or_create_content_warning_#{cw}"] end)}
    end)
    |> Multi.merge(fn %{aggregated_content_warning_records: aggregated_content_warning_records} ->
      Multi.new
      |> Multi.update_all(:content_warning_tagging_counts, ContentWarning |> where([cw], cw.id in ^Enum.map(aggregated_content_warning_records, fn(cw) -> cw.id end)), inc: [tagging_count: 1])
    end)
    |> Multi.run(:put_content_warning_associations, fn %{aggregated_content_warning_records: aggregated_content_warning_records} ->
      Api.Repo.preload(timeline_item, [:content_warnings])
      |> Ecto.Changeset.change
      |> Ecto.Changeset.put_assoc(:content_warnings, aggregated_content_warning_records)
      |> Api.Repo.update
    end)
  end

  def update(timeline_item, current_content_warnings, old_content_warnings) do
    added_content_warnings = current_content_warnings -- old_content_warnings
    removed_content_warnings = old_content_warnings -- current_content_warnings
    all_content_warnings = Enum.uniq(old_content_warnings ++ current_content_warnings)
    content_warning_records = Api.Repo.all(from cw in ContentWarning, where: cw.name in ^all_content_warnings)
    content_warning_record_ids = Enum.map(content_warning_records, fn (cw) -> cw.id end)

    multi = Multi.new
    Enum.reduce(added_content_warnings, multi, fn (content_warning, multi) ->
      multi
      |> Multi.run("find_or_create_content_warning_#{content_warning}", fn %{} ->
        content_warning_record = Enum.find(content_warning_records, fn (content_warning_record) -> content_warning_record.name == content_warning end)

        if (content_warning_record != nil), do: {:ok, content_warning_record}, else: Api.Repo.insert(ContentWarning.changeset(%ContentWarning{}, %{name: content_warning}))
      end)
    end)
    |> Multi.run(:aggregated_content_warning_records, fn args ->
      {:ok, Enum.uniq(Enum.map(added_content_warnings, fn (cw) -> args["find_or_create_content_warning_#{cw}"] end) ++ content_warning_records)}
    end)
    |> Multi.run(:added_content_warning_records, fn %{aggregated_content_warning_records: aggregated_content_warning_records} ->
      {:ok, Enum.map(added_content_warnings, fn (cw) -> Enum.find(aggregated_content_warning_records, fn (cw_record) -> cw_record.name == cw end) end)}
    end)
    |> Multi.run(:removed_content_warning_records, fn %{aggregated_content_warning_records: aggregated_content_warning_records} ->
      {:ok, Enum.map(removed_content_warnings, fn (cw) -> Enum.find(aggregated_content_warning_records, fn (cw_record) -> cw_record.name == cw end) end)}
    end)
    |> Multi.run(:put_content_warning_associations, fn %{added_content_warning_records: added_content_warning_records, removed_content_warning_records: removed_content_warning_records} ->
      timeline_item = Api.Repo.preload(timeline_item, [:content_warnings])

      timeline_item
      |> Ecto.Changeset.change
      |> Ecto.Changeset.put_assoc(:content_warnings, Enum.uniq(timeline_item.content_warnings ++ added_content_warning_records) -- removed_content_warning_records)
      |> Api.Repo.update
    end)
    |> Multi.merge(fn %{added_content_warning_records: added_content_warning_records} ->
      Multi.new
      |> Multi.update_all(:added_content_warning_tagging_counts, ContentWarning |> where([cw], cw.id in ^Enum.map(added_content_warning_records, fn(cw) -> cw.id end)), inc: [tagging_count: 1])
    end)
    |> Multi.merge(fn %{removed_content_warning_records: removed_content_warning_records} ->
      Multi.new
      |> Multi.update_all(:removed_content_warning_tagging_counts, ContentWarning |> where([cw], cw.id in ^Enum.map(removed_content_warning_records, fn(cw) -> cw.id end)), inc: [tagging_count: -1])
    end)
  end
end
