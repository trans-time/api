defmodule ApiWeb.Services.Libra do
  use Timex

  alias ApiWeb.Services.FlagManager
  alias Ecto.Multi

  @infractions %{
    "trolling" => %{
      # ability
      crazy: ~r/c+r+[a@]+z+y+/,
      cripple: ~r/c+r+[i1]+p+l*e*/,
      dumb: ~r/d+u+m+b+/,
      idiot: ~r/[i1]+d+[i1]+[o0]+t+/,
      lame: ~r/l+[a@]+m+[e3]/,
      retard: ~r/r+[e3]+t+[a@]+r+d/,
      stupid: ~r/[s$]+t+u+p+[i1]+d+/,
      ugly: ~r/u+g+l+y/,
      # class
      ghetto: ~r/g+h+[e3]+t+[o0]+/,
      ratchet: ~r/r+[a@]+t+c+h+[e3]+t+/,
      # gay/lesbian
      bugger: ~r/b+u+g+[e3]+r+/,
      carpet_muncher: ~r/(c+[a@]+r+p+[e3]+t+|r+u+g+)[\s-_]*m+u+n+c+h+[e3]+r+/,
      dyke: ~r/d+[iy1]+k+[e3]/,
      fag: ~r/f+[a@]+g+/,
      fudge_packer: ~r/f+u+d+g+[e3]+[\s-_]*p+[a@]+[ck]+[e3]+r+/,
      homo: ~r/h+[o0]+m+[o0]+/,
      lesbo: ~r/l+[e3]+[s$]+b+[o0]+/,
      sodomite: ~r/[s$]+[o0]+d+[o0]+m+/,
      # misogynistic
      bitch: ~r/b+[i1]+t+c+h+/,
      cunt: ~r/c+u+n+t/,
      ho: ~r/(\b|^)h+[o0]+(\b|$)/,
      slut: ~r/[s$]+[l1]+u+t+/,
      thot: ~r/t+h+[o0]+t+/,
      whore: ~r/w*h+[o0]+r+e*/,
      # racial, derived from https://github.com/tinwatchman/grawlix-racism/blob/master/grawlix-racism.js
      chink: ~r/c+h+[i1]+n+k+/,
      darkie: ~r/d+[a@]+r+k+(y+|[i1]+[e3]*)/,
      golliwog: ~r/g[o0][l1][l1][i1y]w[o0]g+/,
      gook: ~r/(\b|^)g+[o0][o0]+k+(?!y)/,
      injun: ~r/[i1]+n+j+u+n+(\b|$)/,
      kaffir: ~r/[ck]+[a@]+(?:f)+[i1e3]*r+/,
      kike: ~r/k+[i1]+k+[e3]+(\b|$)/,
      latrino: ~r/[l1]+[a@]+t+r+[i1]n+[o0]+/,
      negress: ~r/n+[e3]+g+r+[e3]+[s$z]+/,
      nigger: ~r/(\b|^|[^s])[nmwy]+[i1]+g+[e3a@]+[rd]*/,
      raghead: ~r/r+[a@]+g+h+[e3]+[a@]+d+/,
      sambo: ~r/[s$]+[a@]+m+b+[o0]+/,
      shitskin: ~r/[s$]+h+[i1]+t+[s$]+k+[i1]+n+/,
      shvatsa: ~r/[s$z]+h+v+[a@]+t+[s$z]+[a@]+/,
      shvooga: ~r/[s$]+h+v+[o0]+[o0]+g+[a@]+/,
      spic: ~r/(\b|^)[s$]+p+[i1]+[ck]+(\b|$)/,
      squaw: ~r/(\b|^)[s$]+q+u+[a@]+w+(\b|$)/,
      towelhead: ~r/t+[o0]+w+[e3]+[l1]+h+[e3]+[a@]+d+/,
      wetback: ~r/w+[e3]+t+b+[a@]+[ck]+/,
      wog: ~r/(\b|^)w+[o0]+g+(\b|$)/,
      # trans feminine
      dickgirl: ~r/d+[i1]+[ck]+g+[i1]+r+[l1]+/,
      he_she: ~r/h+[e3]+[-_]+[s$]+h+[e3]+/,
      ladyboy: ~r/[l1]+[a@]+d+y+[\s-_]*b+[o0]+[yi]+/,
      mangina: ~r/m+[a@]+n+g+[i1]+n+[a@]+/,
      shemale: ~r/[s$]+h+[e3]+[\s-_]*m+[a@]+[l1]+[e3]+/,
      tranny: ~r/t+r+[a@]+n+[iy]+e*/,
      trap: ~r/t+r+[a@]+p+/,
      # trans masculine
      cuntboy: ~r/c+u+n+t+b+[o0]+[yi1]+/,
      she_he: ~r/[s$]+h+[e3]+[-_]+h+[e3]+/,
      # weight
      blimp: ~r/b+[l1]+[i1]+m+p+/,
      fat: ~r/f+[a@]+t+/,
      hippo: ~r/h+[i1]+p+[o0]/,
      lard: ~r/[l1]+[a@]+r+d/,
      plus_size: ~r/p+[l1]+u+[s$]+[\s-_]*[s$]+[i1]+z+[e3]+/,
      porker: ~r/p+[o0]+r+k+[e3]+r+/,
      obese: ~r/[o0]+b+[e3]+[s$]+([e3]+|([1]+t+y+))/,
      whale: ~r/w+h+[a@]+[l1]+[e3]+/,
    }
  }

  def review(flaggable, text) do
    infractions = Enum.reduce(Map.keys(@infractions), %{categories: [], quotes: []}, fn (category, infractions) ->
      quotes = Enum.reduce(Map.keys(@infractions[category]), [], fn (term, accumulator) ->
        matches = Regex.scan(@infractions[category][term], text)

        if Enum.empty?(matches), do: accumulator, else: List.flatten(matches) ++ accumulator
      end)

      if Enum.empty?(quotes), do: infractions, else: %{
        categories: [category | infractions.categories],
        quotes: quotes ++ infractions.quotes
      }
    end)

    if (Timex.before?(Timex.shift(Timex.now, days: -3), get_flaggable_user(flaggable).inserted_at)) do
      infractions = %{
        categories: infractions.categories,
        quotes: ["account under 3 days old"] ++ infractions.quotes
      }
    end

    if (Enum.empty?(infractions.quotes)) do
      {:ok, flaggable}
    else
      Api.Repo.transaction(Multi.append(
        insert_flag(infractions, flaggable),
        mark_flaggable_as_under_moderation(flaggable)
      ))
    end
  end

  defp mark_flaggable_as_under_moderation(flaggable) do
    Multi.new
    |> Multi.update(:flaggable, flaggable.__struct__.private_changeset(flaggable, %{
      under_moderation: true
    }))
    |> Multi.run(:maybe_timeline_item, fn %{} ->
      FlagManager.put_under_moderation(flaggable)
    end)
  end

  defp insert_flag(infractions, flaggable) do
    FlagManager.insert(Map.merge(%{
      "text" => "Auto-moderated for: #{Enum.join(Enum.uniq(infractions.quotes), ", ")}",
      "user_id" => Api.Repo.get_by!(Api.Accounts.User, username: "libra").id,
      "post_id" => (if flaggable.__struct__ == Api.Timeline.Post, do: flaggable.id, else: nil),
      "comment_id" => (if flaggable.__struct__ == Api.Timeline.Comment, do: flaggable.id, else: nil)
    }, gather_infractions(infractions)))
  end

  defp gather_infractions(infractions) do
    Enum.reduce(infractions.categories, %{}, fn (category, accumulator) ->
      Map.put(accumulator, category, true)
    end)
  end

  defp get_flaggable_user(flaggable) do
    if (flaggable.__struct__ == Api.Timeline.Post) do
      Api.Repo.preload(flaggable, timeline_item: [:user]).timeline_item.user
    else
      Api.Repo.preload(flaggable, :user).user
    end
  end
end
