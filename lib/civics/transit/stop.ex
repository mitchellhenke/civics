defmodule Civics.Transit.Stop do
  use Ecto.Schema
  import Ecto.Changeset

  schema "stops" do
    field :stop_id, :string
    field :stop_name, :string
    field :stop_lat, :float
    field :stop_lon, :float
    field :zone_id, :string
    field :stop_url, :string
    field :stop_desc, :string
    field :stop_code, :string
    field :timepoint, :string
    field :location_type, :integer
    field :route_ids, :binary
    field :feed_id, :id
    field(:geom_point, Civics.EctoTypes.Geometry)
  end

  @doc false
  def changeset(stop, attrs) do
    stop
    |> cast(attrs, [
      :stop_id,
      :stop_name,
      :stop_lat,
      :stop_lon,
      :zone_id,
      :stop_url,
      :stop_desc,
      :stop_code,
      :timepoint,
      :location_type,
      :route_ids
    ])
    |> validate_required([
      :stop_id,
      :stop_name,
      :stop_lat,
      :stop_lon,
      :zone_id,
      :stop_url,
      :stop_desc,
      :stop_code,
      :timepoint,
      :location_type,
      :route_ids
    ])
  end
end
