defmodule Civics.Repo.Migrations.CreateFeeds do
  use Ecto.Migration

  def change do
    create table(:feeds) do
      add :date, :date
    end

    create table(:calendar_dates) do
      add :service_id, :text
      add :date, :date
      add :exception_type, :integer
      add :feed_id, references(:feeds, on_delete: :nothing)
    end

    create table(:routes) do
      add :route_id, :text
      add :route_short_name, :text
      add :route_long_name, :text
      add :route_desc, :text
      add :route_type, :integer
      add :route_url, :text
      add :route_color, :text
      add :route_text_color, :text
      add :feed_id, references(:feeds, on_delete: :nothing)
    end

    create table(:shapes) do
      add :shape_id, :text
      add :shape_pt_lat, :float
      add :shape_pt_lon, :float
      add :shape_pt_sequence, :integer
      add :feed_id, references(:feeds, on_delete: :nothing)
    end

    create table(:shape_geometries) do
      add :length_meters, :float
      add :shape_id, :text
      add :feed_id, references(:feeds, on_delete: :nothing)
    end

    create table(:trips) do
      add :trip_id, :text
      add :route_id, :text
      add :shape_id, :text
      add :service_id, :text
      add :trip_headsign, :text
      add :direction_id, :integer
      add :block_id, :text
      add :length_seconds, :integer
      add :start_time_seconds, :integer
      add :end_time_seconds, :integer
      add :feed_id, references(:feeds, on_delete: :nothing)
    end

    create table(:stops) do
      add :stop_id, :text
      add :stop_name, :text
      add :stop_lat, :float
      add :stop_lon, :float
      add :zone_id, :text
      add :stop_url, :text
      add :stop_desc, :text
      add :stop_code, :text
      add :timepoint, :text
      add :location_type, :integer
      add :route_ids, :binary
      add :feed_id, references(:feeds, on_delete: :nothing)
    end

    create table(:stop_times) do
      add :stop_id, :text
      add :trip_id, :text
      add :arrival_time, :integer
      add :departure_time, :integer
      add :stop_sequence, :integer
      add :stop_headsign, :text
      add :pickup_type, :integer
      add :drop_off_type, :integer
      add :timepoint, :integer
      add :shape_dist_traveled, :float
      add :feed_id, references(:feeds, on_delete: :nothing)
    end

    create index(:stop_times, [:stop_id])
    create index(:trips, [:trip_id])
    create index(:calendar_dates, [:service_id, :date])

    execute(
      "SELECT AddGeometryColumn('stops', 'geom_point', 4326, 'POINT');",
      ""
    )

    execute(
      "SELECT AddGeometryColumn('shapes', 'geom_point', 4326, 'POINT');",
      ""
    )

    execute(
      "SELECT AddGeometryColumn('shape_geometries', 'geom_line', 4326, 'LINESTRING');",
      ""
    )

    execute(
      """
      SELECT CreateSpatialIndex('stops', 'geom_point');
      """,
      """
      """
    )
  end
end
