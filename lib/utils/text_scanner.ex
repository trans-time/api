defmodule Utils.TextScanner do
  def gather_tags(leading_char, text) do
    text = text || ""
    Enum.filter(Enum.uniq(List.flatten(Regex.scan(Regex.compile!("#{leading_char}([a-zA-Z0-9_]+)"), text))), fn (item) -> String.at(item, 0) != leading_char end)
  end
end
