defmodule Civics.Repo.Migrations.CreateNeighborhoods do
  use Ecto.Migration

  def change do
    create table(:neighborhoods) do
      add :name, :text
    end

    execute(
      "SELECT AddGeometryColumn('neighborhoods', 'geom', 4326, 'MULTIPOLYGON');",
      """
      SELECT DiscardGeometryColumn('neighborhoods', 'geom');
      ALTER TABLE neighborhoods DROP COLUMN geom;
      """
    )
  end
end
