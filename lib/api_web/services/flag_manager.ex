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
  end

  def find_or_create_moderation_report(attributes) do
    find_moderation_report(attributes) || create_moderation_report(attributes)
  end

  def find_moderation_report(attributes) do
    cond do
      attributes["post_id"] !== nil -> {:ok, Api.Repo.one(ModerationReport |> where(post_id: ^attributes["post_id"], resolved: ^false))}
      attributes["comment_id"] !== nil -> {:ok, Api.Repo.one(ModerationReport |> where(comment_id: ^attributes["comment_id"], resolved: ^false))}
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
end
