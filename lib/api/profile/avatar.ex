defmodule Api.Profile.Avatar do
  use Arc.Definition
  use Arc.Ecto.Definition
  @acl :public_read
  @versions [:full, :profile, :big_thumb, :thumb]
  @extension_whitelist ~w(.jpg .jpeg .gif .png)

  def transform(:full, _) do
    {:convert, "-strip -thumbnail 1080x1080^ -gravity center -extent 1080x1080 -limit area 10MB -limit disk 100MB"}
  end

  def transform(:profile, _) do
    {:convert, "-strip -thumbnail 145x145^ -gravity center -extent 145x145 -limit area 10MB -limit disk 100MB"}
  end

  def transform(:big_thumb, _) do
    {:convert, "-strip -thumbnail 60x60^ -gravity center -extent 60x60 -limit area 10MB -limit disk 100MB"}
  end

  def transform(:thumb, _) do
    {:convert, "-strip -thumbnail 35x35^ -gravity center -extent 35x35 -limit area 10MB -limit disk 100MB"}
  end

  def validate({file, _}) do
    file_extension = file.file_name |> Path.extname() |> String.downcase()
    Enum.member?(@extension_whitelist, file_extension)
  end

  def storage_dir(version, {file, scope}) do
    "uploads/users/avatars/#{scope.id}"
  end

  def filename(version, _), do: version
end
