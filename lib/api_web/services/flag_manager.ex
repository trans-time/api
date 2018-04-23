import Ecto.Query

defmodule ApiWeb.Services.FlagManager do
  alias Api.Moderation.{Flag, ModerationReport}
  alias Api.Timeline.{Comment, Post}
  alias Ecto.Multi

  def insert(attributes) do
    Multi.new
    |> Multi.run(:moderation_report, fn %{} ->
      find_or_create_moderation_report(attributes)
    end)
    |> Multi.run(:flag, fn %{moderation_report: moderation_report} ->
      Api.Repo.insert(Flag.changeset(%Flag{
        moderation_report_id: moderation_report.id
      }, attributes))
    end)
    |> Multi.run(:put_flaggable_under_moderation, fn %{moderation_report: moderation_report} ->
      unique_flags_by_user = Enum.reduce(Api.Repo.preload(moderation_report, :flags).flags, [], fn (flag, accumulator) ->
        if Enum.any?(accumulator, fn (unique_flag) -> unique_flag.user_id == flag.user_id end), do: accumulator, else: [flag | accumulator]
      end)
      flaggable = cond do
        moderation_report.post_id !== nil -> Api.Repo.preload(moderation_report, :post).post
        moderation_report.comment_id !== nil -> Api.Repo.preload(moderation_report, :comment).comment
      end

      if (Kernel.length(unique_flags_by_user) < 3 || flaggable.ignore_flags) do
        {:ok, moderation_report}
      else
        put_under_moderation(flaggable)
      end
    end)
  end

  def find_or_create_moderation_report(attributes) do
    moderation_report = find_moderation_report(attributes)

    if (moderation_report == nil), do: create_moderation_report(attributes), else: {:ok, moderation_report}
  end

  def find_moderation_report(attributes) do
    cond do
      attributes["post_id"] !== nil -> Api.Repo.one(ModerationReport |> where(post_id: ^attributes["post_id"], resolved: ^false))
      attributes["comment_id"] !== nil -> Api.Repo.one(ModerationReport |> where(comment_id: ^attributes["comment_id"], resolved: ^false))
      true -> nil
    end
  end

  def create_moderation_report(attributes) do
    changeset = ModerationReport.changeset(%ModerationReport{}, %{
      post_id: attributes["post_id"],
      comment_id: attributes["comment_id"],
      indicted_id: find_user_id(attributes)
    })
    Api.Repo.insert(changeset)
  end

  def find_user_id(attributes) do
    cond do
      attributes["post_id"] !== nil -> Api.Repo.one(Post |> where(id: ^attributes["post_id"]) |> preload(:timeline_item)).timeline_item.user_id
      attributes["comment_id"] !== nil -> Api.Repo.one(Comment |> where(id: ^attributes["comment_id"])).user_id
    end
  end

  def put_under_moderation(flaggable) do
    flaggable_changeset = flaggable.__struct__.private_changeset(flaggable, %{under_moderation: true})
    Api.Repo.transaction(
      Multi.new
      |> Multi.update(:flaggable, flaggable_changeset)
      |> Multi.run(:maybe_timeline_item, fn %{} ->
        if (flaggable.__struct__ == Api.Timeline.Post) do
          timeline_item_changeset = Api.Timeline.TimelineItem.private_changeset(Api.Repo.preload(flaggable, :timeline_item).timeline_item, %{under_moderation: true})
          Api.Repo.update(timeline_item_changeset)
        else
          {:ok, flaggable}
        end
      end)
    )
  end
end
