defmodule Civics.Data.Import do
  alias Civics.Repo
  alias Civics.Properties.{Assessment, AssessmentShapefile}

  NimbleCSV.define(Civics.WindowsNewLineCSV,
    separator: ",",
    escape: "\"",
    line_separator: "\r",
    moduledoc: """
    A CSV parser that uses comma as separator and double-quotes as escape according to RFC4180.
    """
  )

  @mprop_download_url "https://data.milwaukee.gov/dataset/562ab824-48a5-42cd-b714-87e205e489ba/resource/0a2c7f31-cd15-4151-8222-09dd57d5f16d/download/mprop.csv"

  def assessments(download \\ false) do
    assessments =
      if download do
        response =
          Finch.build(:get, @mprop_download_url)
          |> Finch.request!(Civics.Finch)

        {"location", download} = List.keyfind(response.headers, "location", 0)

        download_response =
          Finch.build(:get, download)
          |> Finch.request!(Civics.Finch)

        download_response.body
        |> String.trim()
        |> String.split("\r")
      else
        File.read!(Path.join("data", "mprop.csv"))
        |> String.trim()
        |> String.split("\r")
      end

    keys =
      assessments
      |> Enum.take(1)
      |> hd()
      |> String.trim()
      |> Civics.WindowsNewLineCSV.parse_string(skip_headers: false)
      |> hd()

    assessments
    |> Stream.drop(1)
    |> Civics.WindowsNewLineCSV.parse_stream(skip_headers: false)
    |> Stream.map(fn values ->
      map =
        List.zip([keys, values])
        |> Enum.into(%{})

      %{
        tax_key: Map.fetch!(map, "TAXKEY"),
        convey_date: convert_string_maybe_blank_to_date(Map.fetch!(map, "CONVEY_DATE")),
        house_number_low: String.to_integer(Map.fetch!(map, "HOUSE_NR_LO")),
        house_number_high: String.to_integer(Map.fetch!(map, "HOUSE_NR_HI")),
        house_number_suffix: Map.fetch!(map, "HOUSE_NR_SFX"),
        street_direction: Map.fetch!(map, "SDIR"),
        street: Map.fetch!(map, "STREET"),
        street_type: Map.fetch!(map, "STTYPE"),
        tax_rate_cd: String.to_integer(Map.fetch!(map, "TAX_RATE_CD")),
        year: String.to_integer(Map.fetch!(map, "YR_ASSMT")),
        year_built: String.to_integer(Map.fetch!(map, "YR_BUILT")),
        assessed_land: String.to_integer(Map.fetch!(map, "C_A_LAND")),
        assessed_improvements: String.to_integer(Map.fetch!(map, "C_A_IMPRV")),
        assessed_total: String.to_integer(Map.fetch!(map, "C_A_TOTAL")),
        assessed_land_exempt: String.to_integer(Map.fetch!(map, "C_A_EXM_LAND")),
        assessed_improvements_exempt: String.to_integer(Map.fetch!(map, "C_A_EXM_IMPRV")),
        assessed_total_exempt: String.to_integer(Map.fetch!(map, "C_A_EXM_TOTAL")),
        exemption_code: Map.fetch!(map, "C_A_EXM_TYPE"),
        number_units: String.to_integer(Map.fetch!(map, "NR_UNITS")),
        number_of_bedrooms: String.to_integer(Map.fetch!(map, "BEDROOMS")),
        number_of_bathrooms: String.to_integer(Map.fetch!(map, "BATHS")),
        number_of_powder_rooms: String.to_integer(Map.fetch!(map, "POWDER_ROOMS")),
        lot_area: convert_string_maybe_blank_to_float(Map.fetch!(map, "LOT_AREA")),
        zoning: Map.fetch!(map, "ZONING"),
        building_type: Map.fetch!(map, "BLDG_TYPE"),
        building_area: convert_string_maybe_blank_to_float(Map.fetch!(map, "BLDG_AREA")),
        land_use: Map.fetch!(map, "LAND_USE"),
        land_use_general: Map.fetch!(map, "LAND_USE_GP"),
        fireplace: String.to_integer(Map.fetch!(map, "FIREPLACE")),
        air_conditioning: String.to_integer(Map.fetch!(map, "AIR_CONDITIONING")),
        parking_type: Map.fetch!(map, "PARKING_TYPE"),
        number_stories: convert_string_maybe_blank_to_float(Map.fetch!(map, "NR_STORIES")),
        attic: Map.fetch!(map, "ATTIC"),
        basement: Map.fetch!(map, "BASEMENT"),
        convey_type: Map.fetch!(map, "CONVEY_TYPE"),
        owner_name_1: Map.fetch!(map, "OWNER_NAME_1"),
        owner_name_2: Map.fetch!(map, "OWNER_NAME_2"),
        owner_name_3: Map.fetch!(map, "OWNER_NAME_3"),
        owner_mail_address: Map.fetch!(map, "OWNER_MAIL_ADDR"),
        owner_city_state: Map.fetch!(map, "OWNER_CITY_STATE"),
        owner_zip_code: Map.fetch!(map, "OWNER_ZIP"),
        zip_code: Map.fetch!(map, "GEO_ZIP_CODE"),
        owner_occupied: Map.fetch!(map, "OWN_OCPD") == "O",
        alder: Map.fetch!(map, "GEO_ALDER"),
        neighborhood: Map.fetch!(map, "NEIGHBORHOOD"),
        tract: Map.fetch!(map, "GEO_TRACT"),
        block: Map.fetch!(map, "GEO_BLOCK"),
        inserted_at: DateTime.truncate(DateTime.utc_now(), :second),
        updated_at: DateTime.truncate(DateTime.utc_now(), :second)
      }
    end)
    |> Stream.chunk_every(500)
    |> Task.async_stream(fn assessments ->
      {:ok, _} =
        Ecto.Multi.new()
        |> Ecto.Multi.insert_all(:insert_all, Assessment, assessments)
        |> Repo.transaction()
    end)
    |> Stream.run()

    Ecto.Adapters.SQL.query!(
      Repo,
      """
      INSERT INTO assessments_fts (rowid, tax_key, full_address)
      SELECT a.id, a.tax_key,
      house_number_low || ' ' || house_number_high || ' ' || coalesce(street_direction, '') || ' ' || coalesce(street, '') || ' ' || coalesce(street_type, '') || ' ' || coalesce(
      CASE street_type
      WHEN 'AV' THEN 'AVENUE AVE'
      WHEN 'BL' THEN 'BOULEVARD BLVD'
      WHEN 'LA' THEN 'LANE LN'
      WHEN 'ST' THEN 'STREET STR'
      WHEN 'DR' THEN 'DRIVE'
      WHEN 'RD' THEN 'ROAD RD'
      WHEN 'CT' THEN 'CRT COURT CT'
      WHEN 'TR' THEN 'TERRACE TR'
      WHEN 'PK' THEN 'PARKWAY PKWY'
      WHEN 'CR' THEN 'CIRCLE CIR CR'
      WHEN 'WA' THEN 'WAY WY'
      WHEN 'PL' THEN 'PLACE'
      ELSE ''
      END
      , '')
      FROM assessments a
      """
    )
  end

  def assessment_shapefiles(download \\ false) do
    if download do
      {_, 0} =
        Path.join(:code.priv_dir(:civics), "download_shapefiles.sh")
        |> System.cmd([])
    end

    assessments =
      File.read!(Path.join("data", "assessment_shapefiles.geojson"))
      |> Jason.decode!()
      |> Map.fetch!("features")

    assessments
    |> Stream.filter(fn assessment ->
      Map.fetch!(assessment, "geometry")
    end)
    |> Stream.map(fn assessment ->
      tax_key = get_in(assessment, ["properties", "Taxkey"])
      geometry = Geo.JSON.decode!(Map.fetch!(assessment, "geometry"))

      geometry =
        case geometry do
          %Geo.Polygon{} ->
            %Geo.MultiPolygon{coordinates: [geometry.coordinates]}

          %Geo.MultiPolygon{} ->
            geometry
        end

      %{
        tax_key: tax_key,
        geom: %{geometry | srid: 4326}
      }
    end)
    |> Stream.chunk_every(200)
    |> Stream.each(fn assessments ->
      {:ok, _} =
        Ecto.Multi.new()
        |> Ecto.Multi.insert_all(:insert_all, AssessmentShapefile, assessments)
        |> Repo.transaction()
    end)
    |> Stream.run()

    Ecto.Adapters.SQL.query!(
      Repo,
      """
      update assessment_shapefiles SET geom_point = ST_Centroid(geom);
      """
    )
  end

  defp convert_string_maybe_blank_to_date(""), do: nil

  defp convert_string_maybe_blank_to_date(string_date) do
    NaiveDateTime.from_iso8601!(string_date)
    |> NaiveDateTime.to_date()
  end

  defp convert_string_maybe_blank_to_float(""), do: nil

  defp convert_string_maybe_blank_to_float(string_number) do
    {float, ""} = Float.parse(string_number)
    float
  end
end
