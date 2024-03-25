defmodule Civics.Properties.Assessment do
  use Ecto.Schema
  import Ecto.Changeset

  schema "assessments" do
    field :tax_key, :string
    field :tract, :string
    field :owner_name_3, :string
    field :assessed_total, :integer
    field :convey_date, :date
    field :street_direction, :string
    field :house_number_high, :integer
    field :attic, :string
    field :number_stories, :float
    field :house_number_suffix, :string
    field :house_number_low, :integer
    field :alder, :string
    field :lot_area, :float
    field :street_type, :string
    field :number_units, :integer
    field :number_of_powder_rooms, :integer
    field :assessed_land, :integer
    field :owner_name_2, :string
    field :neighborhood, :string
    field :parking_type, :string
    field :assessed_improvements_exempt, :integer
    field :building_area, :float
    field :exemption_code, :string
    field :basement, :string
    field :street, :string
    field :owner_city_state, :string
    field :fireplace, :integer
    field :year_built, :integer
    field :assessed_land_exempt, :integer
    field :owner_zip_code, :string
    field :zoning, :string
    field :owner_occupied, :boolean, default: false
    field :land_use, :string
    field :zip_code, :string
    field :convey_type, :string
    field :owner_name_1, :string
    field :assessed_improvements, :integer
    field :assessed_total_exempt, :integer
    field :block, :string
    field :number_of_bedrooms, :integer
    field :building_type, :string
    field :owner_mail_address, :string
    field :number_of_bathrooms, :integer
    field :tax_rate_cd, :integer
    field :year, :integer
    field :air_conditioning, :integer
    field :land_use_general, :string
    field(:geom_point, Civics.EctoTypes.Geometry, virtual: true)

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(assessment, attrs) do
    assessment
    |> cast(attrs, [
      :tax_key,
      :tax_rate_cd,
      :house_number_high,
      :house_number_low,
      :house_number_suffix,
      :street_direction,
      :street,
      :street_type,
      :year,
      :assessed_land,
      :assessed_improvements,
      :assessed_total,
      :assessed_land_exempt,
      :assessed_improvements_exempt,
      :assessed_total_exempt,
      :exemption_code,
      :building_area,
      :year_built,
      :number_of_bedrooms,
      :number_of_bathrooms,
      :number_of_powder_rooms,
      :lot_area,
      :zoning,
      :building_type,
      :zip_code,
      :land_use,
      :land_use_general,
      :fireplace,
      :air_conditioning,
      :parking_type,
      :number_units,
      :number_stories,
      :attic,
      :basement,
      :neighborhood,
      :tract,
      :block,
      :alder,
      :convey_date,
      :convey_type,
      :owner_name_1,
      :owner_name_2,
      :owner_name_3,
      :owner_mail_address,
      :owner_city_state,
      :owner_zip_code,
      :owner_occupied
    ])
    |> validate_required([
      :tax_key,
      :tax_rate_cd,
      :house_number_high,
      :house_number_low,
      :house_number_suffix,
      :street_direction,
      :street,
      :street_type,
      :year,
      :assessed_land,
      :assessed_improvements,
      :assessed_total,
      :assessed_land_exempt,
      :assessed_improvements_exempt,
      :assessed_total_exempt,
      :exemption_code,
      :building_area,
      :year_built,
      :number_of_bedrooms,
      :number_of_bathrooms,
      :number_of_powder_rooms,
      :lot_area,
      :zoning,
      :building_type,
      :zip_code,
      :land_use,
      :land_use_general,
      :fireplace,
      :air_conditioning,
      :parking_type,
      :number_units,
      :number_stories,
      :attic,
      :basement,
      :neighborhood,
      :tract,
      :block,
      :alder,
      :convey_date,
      :convey_type,
      :owner_name_1,
      :owner_name_2,
      :owner_name_3,
      :owner_mail_address,
      :owner_city_state,
      :owner_zip_code,
      :owner_occupied
    ])
  end

  def address(property) do
    zip_code =
      if property.zip_code do
        String.slice(property.zip_code, 0, 5)
      else
        nil
      end

    house_number =
      if property.house_number_low != property.house_number_high do
        "#{property.house_number_low}-#{property.house_number_high}"
      else
        "#{property.house_number_low}"
      end

    house_number =
      if property.house_number_suffix do
        "#{house_number} #{property.house_number_suffix}"
      else
        "#{house_number}"
      end

    "#{house_number} #{property.street_direction} #{property.street} #{property.street_type}, Milwaukee, WI #{zip_code}"
  end

  def bathroom_count(assessment) do
    case {assessment.number_of_bathrooms, assessment.number_of_powder_rooms} do
      {nil, nil} -> 0
      {br, nil} -> br
      {nil, pr} -> pr * 0.5
      {br, pr} -> br + pr * 0.5
    end
  end
end
