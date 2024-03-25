defmodule Civics.Transit.ShapeGeometry do
  use Ecto.Schema
  import Ecto.Changeset

  schema "shape_geometries" do
    field :length_meters, :float
    field :feed_id, :id
    field :shape_id, :id
  end

  @doc false
  def changeset(shape_geometry, attrs) do
    shape_geometry
    |> cast(attrs, [:length_meters])
    |> validate_required([:length_meters])
  end
end
