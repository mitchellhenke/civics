defmodule Civics.Repo.Migrations.CreateNeighborhoods do
  use Ecto.Migration

  def change do
    create table(:neighborhoods) do
      add :name, :text
    end

    execute(
      "SELECT AddGeometryColumn('neighborhoods', 'geom', 4326, 'MULTIPOLYGON');",
      ""
    )
  end
end
