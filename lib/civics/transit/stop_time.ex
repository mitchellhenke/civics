defmodule Civics.Transit.StopTime do
  use Ecto.Schema
  import Ecto.Changeset

  schema "stop_times" do
    field :stop_id, :string
    field :trip_id, :string
    field :arrival_time, :integer
    field :departure_time, :integer
    field :stop_sequence, :integer
    field :stop_headsign, :string
    field :pickup_type, :integer
    field :drop_off_type, :integer
    field :timepoint, :integer
    field :shape_dist_traveled, :float
    field :feed_id, :id
  end

  @doc false
  def changeset(stop_time, attrs) do
    stop_time
    |> cast(attrs, [
      :arrival_time,
      :departure_time,
      :stop_sequence,
      :stop_headsign,
      :pickup_type,
      :drop_off_type,
      :timepoint,
      :shape_dist_traveled
    ])
    |> validate_required([
      :arrival_time,
      :departure_time,
      :stop_sequence,
      :stop_headsign,
      :pickup_type,
      :drop_off_type,
      :timepoint,
      :shape_dist_traveled
    ])
  end
end
