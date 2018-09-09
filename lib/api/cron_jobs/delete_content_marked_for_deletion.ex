import Ecto.Query

defmodule Api.CronJobs.DeleteContentMarkedForDeletion do
  alias Api.Timeline.{Comment, Image, ImageFile, TimelineItem}

  def call() do
    # datetime = Timex.shift(Timex.now, days: -30)
    # images = from(i in Image, where: i.is_marked_for_deletion == ^true and i.marked_for_deletion_on <= ^datetime)
    # |> Api.Repo.all
    #
    # Enum.each(images, fn image ->
    #   Enum.each(ImageFile.get_versions(), fn version ->
    #     path = ImageFile.url({image.src, image}, version)
    #     [path | _] = String.split path, "?" # strips the "?v=1234" from the URL string
    #     ImageFile.delete({path, image})
    #   end)
    # end)
    #
    # Enum.each([Comment, Image, TimelineItem], fn type ->
    #   from(t in type, where: t.is_marked_for_deletion == ^true and t.marked_for_deletion_on <= ^datetime)
    #   |> Api.Repo.delete_all
    # end)
  end
end
