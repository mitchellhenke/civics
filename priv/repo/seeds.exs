# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Civics.Repo.insert!(%Civics.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

Logger.configure(level: :warning)
Civics.Data.Import.assessments()

Civics.Data.Import.assessment_shapefiles(
  file_path: Path.join("data", "assessment_shapefiles.geojson")
)

Logger.configure(level: :debug)
