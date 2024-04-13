defmodule Civics.Data do
  def import_fly do
    # ./priv/download_shapefiles.sh
    # wireguard
    # scp data/assessment_shapefiles.jsonl root@\[IP\]:/mnt/civics_db
    Civics.Data.Import.assessments(true)

    Civics.Data.Import.assessment_shapefiles(
      Path.join(["/mnt", "civics_db", "assessment_shapefiles.jsonl"])
    )

    Civics.Data.download_gtfs(Path.join(["/mnt", "civics_db"]))

    Civics.Data.Import.import_gtfs(Path.join(["/mnt", "civics_db", "google_transit"]))
  end

  def download_gtfs(destination) do
    response =
      Finch.build(:get, "https://kamino.mcts.org/gtfs/google_transit.zip")
      |> Finch.request!(Civics.Finch)

    File.write(Path.join([destination, "google_transit.zip"]), response.body)

    destination_folder = Path.join([destination, "google_transit"])

    File.mkdir_p!(destination_folder)

    :zip.unzip(String.to_charlist(Path.join([destination, "google_transit.zip"])),
      cwd: String.to_charlist(destination_folder)
    )
  end
end
