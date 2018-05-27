defmodule Api.Profile.Avatar do
  use Arc.Definition
  use Arc.Ecto.Definition
  @acl :public_read
  @versions [:full, :thumb_40, :thumb_80, :thumb_160, :thumb_320, :thumb_640]
  @extension_whitelist ~w(.jpg .jpeg .gif .png)

  def get_versions() do
    @versions
  end

  def transform(:full, _) do
    {:convert, "-colorspace RGB -strip -gravity center -extent 1440x1440 -quality 80 -interlace Plane -colorspace sRGB -limit area 10MB -limit disk 100MB"}
  end

  def transform(:thumb_40, _) do
    {:convert, "-colorspace RGB -strip -gravity center -thumbnail 40x40^ -quality 80 -interlace Plane -colorspace sRGB -limit area 10MB -limit disk 100MB"}
  end

  def transform(:thumb_80, _) do
    {:convert, "-colorspace RGB -strip -gravity center -thumbnail 80x80^ -quality 80 -interlace Plane -colorspace sRGB -limit area 10MB -limit disk 100MB"}
  end

  def transform(:thumb_160, _) do
    {:convert, "-colorspace RGB -strip -gravity center -thumbnail 160x160^ -quality 80 -interlace Plane -colorspace sRGB -limit area 10MB -limit disk 100MB"}
  end

  def transform(:thumb_320, _) do
    {:convert, "-colorspace RGB -strip -gravity center -thumbnail 320x320^ -quality 80 -interlace Plane -colorspace sRGB -limit area 10MB -limit disk 100MB"}
  end

  def transform(:thumb_640, _) do
    {:convert, "-colorspace RGB -strip -gravity center -thumbnail 640x640^ -quality 80 -interlace Plane -colorspace sRGB -limit area 10MB -limit disk 100MB"}
  end

  def transform(:thumb, _) do
    {:convert, "-strip -gravity center -thumbnail 35x35^ -gravity center -extent 35x35 -limit area 10MB -limit disk 100MB"}
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
