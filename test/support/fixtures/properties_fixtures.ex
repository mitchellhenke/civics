defmodule Civics.PropertiesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Civics.Properties` context.
  """

  @doc """
  Generate a assessment.
  """
  def assessment_fixture(attrs \\ %{}) do
    {:ok, assessment} =
      attrs
      |> Enum.into(%{
        air_conditioning: 42,
        alder: "some alder",
        assessed_improvements: 42,
        assessed_improvements_exempt: 42,
        assessed_land: 42,
        assessed_land_exempt: 42,
        assessed_total: 42,
        assessed_total_exempt: 42,
        attic: "some attic",
        basement: "some basement",
        block: "some block",
        building_area: 42,
        building_type: "some building_type",
        convey_date: ~D[2024-03-02],
        convey_type: "some convey_type",
        exemption_code: "some exemption_code",
        fireplace: 42,
        house_number_high: 42,
        house_number_low: 42,
        house_number_suffix: "some house_number_suffix",
        land_use: "some land_use",
        land_use_general: "some land_use_general",
        lot_area: 42,
        neighborhood: "some neighborhood",
        number_of_bathrooms: 42,
        number_of_bedrooms: 42,
        number_of_powder_rooms: 42,
        number_stories: 120.5,
        number_units: 42,
        owner_city_state: "some owner_city_state",
        owner_mail_address: "some owner_mail_address",
        owner_name_1: "some owner_name_1",
        owner_name_2: "some owner_name_2",
        owner_name_3: "some owner_name_3",
        owner_occupied: true,
        owner_zip_code: "some owner_zip_code",
        parking_type: "some parking_type",
        street: "some street",
        street_direction: "some street_direction",
        street_type: "some street_type",
        tax_rate_cd: 42,
        tax_key: "some tax key",
        tract: "some tract",
        year: 42,
        year_built: 42,
        zip_code: "some zip_code",
        zoning: "some zoning"
      })
      |> Civics.Properties.create_assessment()

    assessment
  end
end
