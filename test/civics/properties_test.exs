defmodule Civics.PropertiesTest do
  use Civics.DataCase

  alias Civics.Properties

  describe "assessments" do
    alias Civics.Properties.Assessment

    import Civics.PropertiesFixtures

    @invalid_attrs %{
      land_use_general: nil,
      air_conditioning: nil,
      year: nil,
      tax_rate_cd: nil,
      number_of_bathrooms: nil,
      owner_mail_address: nil,
      building_type: nil,
      number_of_bedrooms: nil,
      block: nil,
      assessed_total_exempt: nil,
      assessed_improvements: nil,
      owner_name_1: nil,
      convey_type: nil,
      zip_code: nil,
      land_use: nil,
      owner_occupied: nil,
      zoning: nil,
      owner_zip_code: nil,
      assessed_land_exempt: nil,
      year_built: nil,
      fireplace: nil,
      owner_city_state: nil,
      street: nil,
      basement: nil,
      exemption_code: nil,
      building_area: nil,
      assessed_improvements_exempt: nil,
      parking_type: nil,
      neighborhood: nil,
      owner_name_2: nil,
      assessed_land: nil,
      number_of_powder_rooms: nil,
      number_units: nil,
      street_type: nil,
      lot_area: nil,
      alder: nil,
      house_number_low: nil,
      house_number_suffix: nil,
      number_stories: nil,
      attic: nil,
      house_number_high: nil,
      street_direction: nil,
      convey_date: nil,
      assessed_total: nil,
      owner_name_3: nil,
      tract: nil,
      tax_key: nil
    }

    test "list_assessments/0 returns all assessments" do
      assessment = assessment_fixture()
      assert Properties.list_assessments() == [assessment]
    end

    test "get_assessment!/1 returns the assessment with given id" do
      assessment = assessment_fixture()
      assert Properties.get_assessment!(assessment.id) == assessment
    end

    test "create_assessment/1 with valid data creates a assessment" do
      valid_attrs = %{
        land_use_general: "some land_use_general",
        air_conditioning: 42,
        year: 42,
        tax_rate_cd: 42,
        number_of_bathrooms: 42,
        owner_mail_address: "some owner_mail_address",
        building_type: "some building_type",
        number_of_bedrooms: 42,
        block: "some block",
        assessed_total_exempt: 42,
        assessed_improvements: 42,
        owner_name_1: "some owner_name_1",
        convey_type: "some convey_type",
        zip_code: "some zip_code",
        land_use: "some land_use",
        owner_occupied: true,
        zoning: "some zoning",
        owner_zip_code: "some owner_zip_code",
        assessed_land_exempt: 42,
        year_built: 42,
        fireplace: 42,
        owner_city_state: "some owner_city_state",
        street: "some street",
        basement: "some basement",
        exemption_code: "some exemption_code",
        building_area: 42,
        assessed_improvements_exempt: 42,
        parking_type: "some parking_type",
        neighborhood: "some neighborhood",
        owner_name_2: "some owner_name_2",
        assessed_land: 42,
        number_of_powder_rooms: 42,
        number_units: 42,
        street_type: "some street_type",
        lot_area: 42,
        alder: "some alder",
        house_number_low: 42,
        house_number_suffix: "some house_number_suffix",
        number_stories: 120.5,
        attic: "some attic",
        house_number_high: 42,
        street_direction: "some street_direction",
        convey_date: ~D[2024-03-02],
        assessed_total: 42,
        owner_name_3: "some owner_name_3",
        tract: "some tract",
        tax_key: "some tax key"
      }

      assert {:ok, %Assessment{} = assessment} = Properties.create_assessment(valid_attrs)
      assert assessment.tax_key == "some tax key"
      assert assessment.tract == "some tract"
      assert assessment.owner_name_3 == "some owner_name_3"
      assert assessment.assessed_total == 42
      assert assessment.convey_date == ~D[2024-03-02]
      assert assessment.street_direction == "some street_direction"
      assert assessment.house_number_high == 42
      assert assessment.attic == "some attic"
      assert assessment.number_stories == 120.5
      assert assessment.house_number_suffix == "some house_number_suffix"
      assert assessment.house_number_low == 42
      assert assessment.alder == "some alder"
      assert assessment.lot_area == 42
      assert assessment.street_type == "some street_type"
      assert assessment.number_units == 42
      assert assessment.number_of_powder_rooms == 42
      assert assessment.assessed_land == 42
      assert assessment.owner_name_2 == "some owner_name_2"
      assert assessment.neighborhood == "some neighborhood"
      assert assessment.parking_type == "some parking_type"
      assert assessment.assessed_improvements_exempt == 42
      assert assessment.building_area == 42
      assert assessment.exemption_code == "some exemption_code"
      assert assessment.basement == "some basement"
      assert assessment.street == "some street"
      assert assessment.owner_city_state == "some owner_city_state"
      assert assessment.fireplace == 42
      assert assessment.year_built == 42
      assert assessment.assessed_land_exempt == 42
      assert assessment.owner_zip_code == "some owner_zip_code"
      assert assessment.zoning == "some zoning"
      assert assessment.owner_occupied == true
      assert assessment.land_use == "some land_use"
      assert assessment.zip_code == "some zip_code"
      assert assessment.convey_type == "some convey_type"
      assert assessment.owner_name_1 == "some owner_name_1"
      assert assessment.assessed_improvements == 42
      assert assessment.assessed_total_exempt == 42
      assert assessment.block == "some block"
      assert assessment.number_of_bedrooms == 42
      assert assessment.building_type == "some building_type"
      assert assessment.owner_mail_address == "some owner_mail_address"
      assert assessment.number_of_bathrooms == 42
      assert assessment.tax_rate_cd == 42
      assert assessment.year == 42
      assert assessment.air_conditioning == 42
      assert assessment.land_use_general == "some land_use_general"
    end

    test "create_assessment/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Properties.create_assessment(@invalid_attrs)
    end

    test "update_assessment/2 with valid data updates the assessment" do
      assessment = assessment_fixture()

      update_attrs = %{
        land_use_general: "some updated land_use_general",
        air_conditioning: 43,
        year: 43,
        tax_rate_cd: 43,
        number_of_bathrooms: 43,
        owner_mail_address: "some updated owner_mail_address",
        building_type: "some updated building_type",
        number_of_bedrooms: 43,
        block: "some updated block",
        assessed_total_exempt: 43,
        assessed_improvements: 43,
        owner_name_1: "some updated owner_name_1",
        convey_type: "some updated convey_type",
        zip_code: "some updated zip_code",
        land_use: "some updated land_use",
        owner_occupied: false,
        zoning: "some updated zoning",
        owner_zip_code: "some updated owner_zip_code",
        assessed_land_exempt: 43,
        year_built: 43,
        fireplace: 43,
        owner_city_state: "some updated owner_city_state",
        street: "some updated street",
        basement: "some updated basement",
        exemption_code: "some updated exemption_code",
        building_area: 43,
        assessed_improvements_exempt: 43,
        parking_type: "some updated parking_type",
        neighborhood: "some updated neighborhood",
        owner_name_2: "some updated owner_name_2",
        assessed_land: 43,
        number_of_powder_rooms: 43,
        number_units: 43,
        street_type: "some updated street_type",
        lot_area: 43,
        alder: "some updated alder",
        house_number_low: 43,
        house_number_suffix: "some updated house_number_suffix",
        number_stories: 456.7,
        attic: "some updated attic",
        house_number_high: 43,
        street_direction: "some updated street_direction",
        convey_date: ~D[2024-03-03],
        assessed_total: 43,
        owner_name_3: "some updated owner_name_3",
        tract: "some updated tract",
        tax_key: "some updated tax key"
      }

      assert {:ok, %Assessment{} = assessment} =
               Properties.update_assessment(assessment, update_attrs)

      assert assessment.tax_key == "some updated tax key"
      assert assessment.tract == "some updated tract"
      assert assessment.owner_name_3 == "some updated owner_name_3"
      assert assessment.assessed_total == 43
      assert assessment.convey_date == ~D[2024-03-03]
      assert assessment.street_direction == "some updated street_direction"
      assert assessment.house_number_high == 43
      assert assessment.attic == "some updated attic"
      assert assessment.number_stories == 456.7
      assert assessment.house_number_suffix == "some updated house_number_suffix"
      assert assessment.house_number_low == 43
      assert assessment.alder == "some updated alder"
      assert assessment.lot_area == 43
      assert assessment.street_type == "some updated street_type"
      assert assessment.number_units == 43
      assert assessment.number_of_powder_rooms == 43
      assert assessment.assessed_land == 43
      assert assessment.owner_name_2 == "some updated owner_name_2"
      assert assessment.neighborhood == "some updated neighborhood"
      assert assessment.parking_type == "some updated parking_type"
      assert assessment.assessed_improvements_exempt == 43
      assert assessment.building_area == 43
      assert assessment.exemption_code == "some updated exemption_code"
      assert assessment.basement == "some updated basement"
      assert assessment.street == "some updated street"
      assert assessment.owner_city_state == "some updated owner_city_state"
      assert assessment.fireplace == 43
      assert assessment.year_built == 43
      assert assessment.assessed_land_exempt == 43
      assert assessment.owner_zip_code == "some updated owner_zip_code"
      assert assessment.zoning == "some updated zoning"
      assert assessment.owner_occupied == false
      assert assessment.land_use == "some updated land_use"
      assert assessment.zip_code == "some updated zip_code"
      assert assessment.convey_type == "some updated convey_type"
      assert assessment.owner_name_1 == "some updated owner_name_1"
      assert assessment.assessed_improvements == 43
      assert assessment.assessed_total_exempt == 43
      assert assessment.block == "some updated block"
      assert assessment.number_of_bedrooms == 43
      assert assessment.building_type == "some updated building_type"
      assert assessment.owner_mail_address == "some updated owner_mail_address"
      assert assessment.number_of_bathrooms == 43
      assert assessment.tax_rate_cd == 43
      assert assessment.year == 43
      assert assessment.air_conditioning == 43
      assert assessment.land_use_general == "some updated land_use_general"
    end

    test "update_assessment/2 with invalid data returns error changeset" do
      assessment = assessment_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Properties.update_assessment(assessment, @invalid_attrs)

      assert assessment == Properties.get_assessment!(assessment.id)
    end

    test "delete_assessment/1 deletes the assessment" do
      assessment = assessment_fixture()
      assert {:ok, %Assessment{}} = Properties.delete_assessment(assessment)
      assert_raise Ecto.NoResultsError, fn -> Properties.get_assessment!(assessment.id) end
    end

    test "change_assessment/1 returns a assessment changeset" do
      assessment = assessment_fixture()
      assert %Ecto.Changeset{} = Properties.change_assessment(assessment)
    end
  end
end
