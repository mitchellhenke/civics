defmodule Civics.Data do
  @mprop_download_url "https://data.milwaukee.gov/dataset/562ab824-48a5-42cd-b714-87e205e489ba/resource/0a2c7f31-cd15-4151-8222-09dd57d5f16d/download/mprop.csv"

  def import_fly do
    # ./priv/download_shapefiles.sh
    # wireguard
    # scp data/assessment_shapefiles.jsonl root@\[IP\]:/mnt/civics_db
    assessment_path = Path.join([Application.fetch_env!(:civics, :download_path), "mprop.csv"])
    Civics.Data.download_assessments(assessment_path)
    Civics.Data.Import.assessments(assessment_path)

    Civics.Data.Import.assessment_shapefiles(
      Path.join(["/mnt", "civics_db", "assessment_shapefiles.jsonl"])
    )

    Civics.Data.download_gtfs(Application.fetch_env!(:civics, :download_path))

    Civics.Data.Import.import_gtfs(
      Path.join([Application.fetch_env!(:civics, :download_path), "google_transit"])
    )
  end

  def download_assessments(file_path) do
    response =
      Finch.build(:get, @mprop_download_url)
      |> Finch.request!(Civics.Finch)

    {"location", location} = List.keyfind(response.headers, "location", 0)

    download_response =
      Finch.build(:get, location)
      |> Finch.request!(Civics.Finch)

    File.write!(file_path, String.replace(download_response.body, "\r", "\n"))
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
