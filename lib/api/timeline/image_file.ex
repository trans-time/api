defmodule Api.Timeline.ImageFile do
  use Arc.Definition
  use Arc.Ecto.Definition
  @acl :public_read
  @versions [:full_375, :full_750, :full_1080, :full_1440]
  @extension_whitelist ~w(.jpg .jpeg .gif .png)

  def get_versions() do
    @versions
  end

  def transform(:full_375, _) do
    {:convert, "-strip -colorspace RGB -gravity center -extent 1440x1800 -resize 375x469 -quality 80 -interlace Plane -colorspace sRGB -limit area 10MB -limit disk 100MB"}
  end

  def transform(:full_750, _) do
    {:convert, "-strip -colorspace RGB -gravity center -extent 1440x1800 -resize 750x938 -quality 80 -interlace Plane -colorspace sRGB -limit area 10MB -limit disk 100MB"}
  end

  def transform(:full_1080, _) do
    {:convert, "-strip -colorspace RGB -gravity center -extent 1440x1800 -resize 1080x1350 -quality 80 -interlace Plane -colorspace sRGB -limit area 10MB -limit disk 100MB"}
  end

  def transform(:full_1440, _) do
    {:convert, "-strip -colorspace RGB -gravity center -extent 1440x1800 -quality 80 -interlace Plane -colorspace sRGB -limit area 10MB -limit disk 100MB"}
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
