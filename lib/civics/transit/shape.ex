defmodule Civics.Transit.Shape do
  use Ecto.Schema
  import Ecto.Changeset

  schema "shapes" do
    field :shape_id, :string
    field :shape_pt_lat, :float
    field :shape_pt_lon, :float
    field :shape_pt_sequence, :integer
    field :feed_id, :id
  end

  @doc false
  def changeset(shape, attrs) do
    shape
    |> cast(attrs, [:shape_id, :shape_pt_lat, :shape_pt_lon, :shape_pt_sequence])
    |> validate_required([:shape_id, :shape_pt_lat, :shape_pt_lon, :shape_pt_sequence])
  end
end
