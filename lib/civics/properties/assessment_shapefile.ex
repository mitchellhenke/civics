defmodule Civics.Properties.AssessmentShapefile do
  use Ecto.Schema
  import Ecto.Changeset

  schema "assessment_shapefiles" do
    field(:tax_key, :string)
    field(:geom_point, Civics.EctoTypes.Geometry)
    field(:geom, Civics.EctoTypes.Geometry)
  end

  @doc false
  def changeset(assessment_shapefile, attrs) do
    assessment_shapefile
    |> cast(attrs, [
      :tax_key,
      :geom_point,
      :geom
    ])
    |> validate_required([
      :tax_key
    ])
  end
end
