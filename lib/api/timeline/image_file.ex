defmodule Api.Timeline.ImageFile do
  use Arc.Definition
  use Arc.Ecto.Definition
  @acl :public_read
  @versions [:full]
  @extension_whitelist ~w(.jpg .jpeg .gif .png)

  def get_versions() do
    @versions
  end

  def transform(:full, _) do
    {:convert, "-strip -gravity center -extent 1080x1350 -limit area 10MB -limit disk 100MB"}
  end

  def validate({file, _}) do
    file_extension = file.file_name |> Path.extname() |> String.downcase()
    Enum.member?(@extension_whitelist, file_extension)
  end

  def storage_dir(version, scope) do
    "uploads/images/#{elem(scope, 1).id}"
  end

  def filename(version, _), do: version
end
