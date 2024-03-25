defmodule Civics.Transit.Trip do
  use Ecto.Schema
  import Ecto.Changeset

  schema "trips" do
    field :trip_id, :string
    field :route_id, :string
    field :shape_id, :string
    field :service_id, :string
    field :trip_headsign, :string
    field :direction_id, :integer
    field :block_id, :string
    field :length_seconds, :integer
    field :start_time_seconds, :integer
    field :end_time_seconds, :integer
    field :feed_id, :id
  end

  @doc false
  def changeset(trip, attrs) do
    trip
    |> cast(attrs, [
      :trip_id,
      :service_id,
      :trip_headsign,
      :direction_id,
      :block_id,
      :length_seconds,
      :start_time_seconds,
      :end_time_seconds
    ])
    |> validate_required([
      :trip_id,
      :service_id,
      :trip_headsign,
      :direction_id,
      :block_id,
      :length_seconds,
      :start_time_seconds,
      :end_time_seconds
    ])
  end
end
