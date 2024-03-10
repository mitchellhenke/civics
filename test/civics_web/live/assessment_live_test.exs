defmodule CivicsWeb.AssessmentLiveTest do
  use CivicsWeb.ConnCase

  import Phoenix.LiveViewTest
  import Civics.PropertiesFixtures

  @create_attrs %{
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
    convey_date: "2024-03-02",
    assessed_total: 42,
    owner_name_3: "some owner_name_3",
    tract: "some tract",
    tax_key: "some tax key"
  }
  @update_attrs %{
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
    convey_date: "2024-03-03",
    assessed_total: 43,
    owner_name_3: "some updated owner_name_3",
    tract: "some updated tract",
    tax_key: "some updated tax key"
  }
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
    owner_occupied: false,
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

  defp create_assessment(_) do
    assessment = assessment_fixture()
    %{assessment: assessment}
  end

  describe "Index" do
    setup [:create_assessment]

    test "lists all assessments", %{conn: conn, assessment: assessment} do
      {:ok, _index_live, html} = live(conn, ~p"/assessments")

      assert html =~ "Listing Assessments"
      assert html =~ assessment.land_use_general
    end

    test "saves new assessment", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/assessments")

      assert index_live |> element("a", "New Assessment") |> render_click() =~
               "New Assessment"

      assert_patch(index_live, ~p"/assessments/new")

      assert index_live
             |> form("#assessment-form", assessment: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#assessment-form", assessment: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/assessments")

      html = render(index_live)
      assert html =~ "Assessment created successfully"
      assert html =~ "some land_use_general"
    end

    test "updates assessment in listing", %{conn: conn, assessment: assessment} do
      {:ok, index_live, _html} = live(conn, ~p"/assessments")

      assert index_live |> element("#assessments-#{assessment.id} a", "Edit") |> render_click() =~
               "Edit Assessment"

      assert_patch(index_live, ~p"/assessments/#{assessment}/edit")

      assert index_live
             |> form("#assessment-form", assessment: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#assessment-form", assessment: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/assessments")

      html = render(index_live)
      assert html =~ "Assessment updated successfully"
      assert html =~ "some updated land_use_general"
    end

    test "deletes assessment in listing", %{conn: conn, assessment: assessment} do
      {:ok, index_live, _html} = live(conn, ~p"/assessments")

      assert index_live |> element("#assessments-#{assessment.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#assessments-#{assessment.id}")
    end
  end

  describe "Show" do
    setup [:create_assessment]

    test "displays assessment", %{conn: conn, assessment: assessment} do
      {:ok, _show_live, html} = live(conn, ~p"/assessments/#{assessment}")

      assert html =~ "Show Assessment"
      assert html =~ assessment.land_use_general
    end

    test "updates assessment within modal", %{conn: conn, assessment: assessment} do
      {:ok, show_live, _html} = live(conn, ~p"/assessments/#{assessment}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Assessment"

      assert_patch(show_live, ~p"/assessments/#{assessment}/show/edit")

      assert show_live
             |> form("#assessment-form", assessment: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#assessment-form", assessment: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/assessments/#{assessment}")

      html = render(show_live)
      assert html =~ "Assessment updated successfully"
      assert html =~ "some updated land_use_general"
    end
  end
end
