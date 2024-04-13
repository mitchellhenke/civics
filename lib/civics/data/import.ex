defmodule Civics.Data.Import do
  alias Civics.Repo
  alias Civics.Properties.{Assessment, AssessmentShapefile}
  alias Civics.Transit.{Feed, Route, CalendarDate, Stop, Trip, StopTime}

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
      SUBSTR(house_number_low, 0,LENGTH(house_number_low)) || ' ' ||
      SUBSTR(house_number_low, 0,LENGTH(house_number_low) - 1) || '00' || ' ' ||
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

  def assessment_shapefiles(file_path) do
    Ecto.Adapters.SQL.query!(
      Repo,
      """
      DELETE FROM assessment_shapefiles;
      """
    )

    _assessments =
      File.stream!(file_path)
      |> Stream.map(fn assessment_json ->
        assessment = Jason.decode!(assessment_json)
        tax_key = get_in(assessment, ["properties", "Taxkey"])

        geometry =
          case Map.fetch!(assessment, "geometry") do
            nil ->
              nil

            geo ->
              Geo.JSON.decode!(geo)
          end

        geometry =
          case geometry do
            %Geo.Polygon{} ->
              %Geo.MultiPolygon{coordinates: [geometry.coordinates], srid: 4326}

            %Geo.MultiPolygon{} ->
              %{geometry | srid: 4326}

            nil ->
              nil
          end

        %{
          tax_key: tax_key,
          geom: geometry
        }
      end)
      |> Stream.filter(fn assessment ->
        Map.fetch!(assessment, :geom)
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

  def import_gtfs(folder \\ "./data/google_transit", date \\ Date.utc_today()) do
    ["stops", "routes", "calendar_dates", "shapes", "trips", "stop_times"]
    |> Enum.each(fn table ->
      Ecto.Adapters.SQL.query!(Repo, "DELETE FROM #{table};")
    end)

    feed =
      Feed.changeset(%Feed{}, %{date: date})
      |> Repo.insert!()

    feed_id = feed.id

    routes =
      File.read!(Path.join([folder, "routes.txt"]))
      |> String.trim()
      |> String.split("\r\n")

    keys =
      routes
      |> Enum.take(1)
      |> hd()
      |> String.trim()
      |> NimbleCSV.RFC4180.parse_string(skip_headers: false)
      |> hd()

    routes
    |> Stream.drop(1)
    |> NimbleCSV.RFC4180.parse_stream(skip_headers: false)
    |> Stream.map(fn values ->
      map =
        List.zip([keys, values])
        |> Enum.into(%{})

      %{
        route_id: Map.fetch!(map, "route_id"),
        route_short_name: Map.fetch!(map, "route_short_name"),
        route_long_name: Map.fetch!(map, "route_long_name"),
        route_desc: Map.fetch!(map, "route_desc"),
        route_type: String.to_integer(Map.fetch!(map, "route_type")),
        route_url: Map.fetch!(map, "route_url"),
        route_color: Map.fetch!(map, "route_color"),
        route_text_color: Map.fetch!(map, "route_text_color"),
        feed_id: feed_id
      }
    end)
    |> Stream.chunk_every(500)
    |> Task.async_stream(fn routes ->
      {:ok, _} =
        Ecto.Multi.new()
        |> Ecto.Multi.insert_all(:insert_all, Route, routes)
        |> Repo.transaction()
    end)
    |> Stream.run()

    earliest_date = Date.add(Date.utc_today(), -2)
    latest_date = Date.add(Date.utc_today(), 11)

    calendar_dates =
      File.read!(Path.join(folder, "calendar_dates.txt"))
      |> String.trim()
      |> String.split("\r\n")

    keys =
      calendar_dates
      |> Enum.take(1)
      |> hd()
      |> String.trim()
      |> NimbleCSV.RFC4180.parse_string(skip_headers: false)
      |> hd()

    calendar_dates =
      Stream.drop(calendar_dates, 1)
      |> NimbleCSV.RFC4180.parse_stream(skip_headers: false)
      |> Stream.map(fn values ->
        map =
          List.zip([keys, values])
          |> Enum.into(%{})

        date = Map.fetch!(map, "date")
        year = String.slice(date, 0, 4)
        month = String.slice(date, 4, 2)
        day = String.slice(date, 6, 2)

        %{
          exception_type: String.to_integer(Map.fetch!(map, "exception_type")),
          service_id: Map.fetch!(map, "service_id"),
          date: Date.from_iso8601!("#{year}-#{month}-#{day}"),
          feed_id: feed_id
        }
      end)
      |> Stream.filter(fn calendar_date ->
        Date.compare(calendar_date.date, latest_date) == :lt &&
          Date.compare(calendar_date.date, earliest_date) == :gt
      end)
      |> Stream.chunk_every(500)
      |> Task.async_stream(fn calendar_dates ->
        {:ok, _} =
          Ecto.Multi.new()
          |> Ecto.Multi.insert_all(:insert_all, CalendarDate, calendar_dates)
          |> Repo.transaction()

        calendar_dates
      end)
      |> Enum.map(&elem(&1, 1))
      |> List.flatten()

    service_ids =
      Enum.map(calendar_dates, & &1.service_id)
      |> MapSet.new()

    stops =
      File.read!(Path.join(folder, "stops.txt"))
      |> String.trim()
      |> String.split("\r\n")

    keys =
      stops
      |> Enum.take(1)
      |> hd()
      |> String.trim()
      |> NimbleCSV.RFC4180.parse_string(skip_headers: false)
      |> hd()

    stops
    |> Stream.drop(1)
    |> NimbleCSV.RFC4180.parse_stream(skip_headers: false)
    |> Stream.map(fn values ->
      map =
        List.zip([keys, values])
        |> Enum.into(%{})

      %{
        stop_lat: String.to_float(Map.fetch!(map, "stop_lat")),
        stop_code: Map.fetch!(map, "stop_code"),
        stop_lon: String.to_float(Map.fetch!(map, "stop_lon")),
        timepoint: Map.fetch!(map, "timepoint"),
        stop_url: Map.fetch!(map, "stop_url"),
        stop_id: Map.fetch!(map, "stop_id"),
        stop_desc: Map.fetch!(map, "stop_desc"),
        stop_name: Map.fetch!(map, "stop_name"),
        # location_type: String.to_integer(Map.fetch!(map, "location_type")),
        zone_id: Map.fetch!(map, "zone_id"),
        feed_id: feed_id
      }
    end)
    |> Stream.chunk_every(500)
    |> Stream.each(fn stops ->
      {:ok, _} =
        Ecto.Multi.new()
        |> Ecto.Multi.insert_all(:insert_all, Stop, stops)
        |> Repo.transaction()
    end)
    |> Stream.run()

    # shapes =
    #   File.read!(Path.join(folder, "shapes.txt"))
    #   |> String.trim()
    #   |> String.split("\r\n")

    # keys =
    #   shapes
    #   |> Enum.take(1)
    #   |> hd()
    #   |> String.trim()
    #   |> NimbleCSV.RFC4180.parse_string(skip_headers: false)
    #   |> hd()

    # shapes
    # |> Stream.drop(1)
    # |> NimbleCSV.RFC4180.parse_stream(skip_headers: false)
    # |> Stream.map(fn values ->
    #   map =
    #     List.zip([keys, values])
    #     |> Enum.into(%{})

    #   %{
    #     shape_pt_lat: String.to_float(Map.fetch!(map, "shape_pt_lat")),
    #     shape_pt_lon: String.to_float(Map.fetch!(map, "shape_pt_lon")),
    #     shape_pt_sequence: String.to_integer(Map.fetch!(map, "shape_pt_sequence")),
    #     shape_id: Map.fetch!(map, "shape_id"),
    #     feed_id: feed_id,
    #   }
    # end)
    # |> Stream.chunk_every(500)
    # |> Task.async_stream(fn shapes ->
    #   {:ok, _} =
    #     Ecto.Multi.new()
    #     |> Ecto.Multi.insert_all(:insert_all, Shape, shapes)
    #     |> Repo.transaction()
    # end)
    # |> Stream.run()

    trips =
      File.stream!(Path.join(folder, "trips.txt"))
      |> Enum.take(1)
      |> hd()
      |> String.trim()

    keys =
      trips
      |> NimbleCSV.RFC4180.parse_string(skip_headers: false)
      |> hd()

    trips =
      File.stream!(Path.join(folder, "trips.txt"))
      |> Stream.drop(1)
      |> NimbleCSV.RFC4180.parse_stream(skip_headers: false)
      |> Stream.map(fn values ->
        map =
          List.zip([keys, values])
          |> Enum.into(%{})

        # add :length_seconds, :integer
        # add :start_time_seconds, :integer
        # add :end_time_seconds, :integer
        %{
          shape_id: Map.fetch!(map, "shape_id"),
          route_id: Map.fetch!(map, "route_id"),
          trip_id: Map.fetch!(map, "trip_id"),
          service_id: Map.fetch!(map, "service_id"),
          trip_headsign: Map.fetch!(map, "trip_headsign"),
          direction_id: String.to_integer(Map.fetch!(map, "direction_id")),
          block_id: Map.fetch!(map, "block_id"),
          feed_id: feed_id
        }
      end)
      |> Stream.filter(fn trip ->
        MapSet.member?(service_ids, trip.service_id)
      end)
      |> Stream.chunk_every(500)
      |> Task.async_stream(fn trips ->
        {:ok, _} =
          Ecto.Multi.new()
          |> Ecto.Multi.insert_all(:insert_all, Trip, trips)
          |> Repo.transaction()

        trips
      end)
      |> Enum.map(&elem(&1, 1))
      |> List.flatten()

    trip_ids =
      Enum.map(trips, & &1.trip_id)
      |> MapSet.new()

    stop_times =
      File.stream!(Path.join(folder, "stop_times.txt"))
      |> Enum.take(1)
      |> hd()
      |> String.trim()

    keys =
      stop_times
      |> NimbleCSV.RFC4180.parse_string(skip_headers: false)
      |> hd()

    File.stream!(Path.join(folder, "stop_times.txt"))
    |> Stream.drop(1)
    |> NimbleCSV.RFC4180.parse_stream(skip_headers: false)
    |> Stream.filter(fn values ->
      map =
        List.zip([keys, values])
        |> Enum.into(%{})

      Enum.count(Map.keys(map)) > 1
    end)
    |> Stream.map(fn values ->
      map =
        List.zip([keys, values])
        |> Enum.into(%{})

      [arrival_hours, arrival_minutes, arrival_seconds] =
        Map.fetch!(map, "arrival_time")
        |> String.split(":")
        |> Enum.map(&String.to_integer/1)

      [departure_hours, departure_minutes, departure_seconds] =
        Map.fetch!(map, "departure_time")
        |> String.split(":")
        |> Enum.map(&String.to_integer/1)

      arrival_time_seconds = arrival_hours * 60 * 60 + arrival_minutes * 60 + arrival_seconds

      departure_time_seconds =
        departure_hours * 60 * 60 + departure_minutes * 60 + departure_seconds

      # add(:shape_dist_traveled, :float)
      %{
        stop_id: Map.fetch!(map, "stop_id"),
        trip_id: Map.fetch!(map, "trip_id"),
        arrival_time: arrival_time_seconds,
        departure_time: departure_time_seconds,
        stop_sequence: String.to_integer(Map.fetch!(map, "stop_sequence")),
        stop_headsign: Map.fetch!(map, "stop_headsign"),
        pickup_type: convert_string_maybe_blank_to_integer(Map.fetch!(map, "pickup_type")),
        drop_off_type: convert_string_maybe_blank_to_integer(Map.fetch!(map, "drop_off_type")),
        timepoint: convert_string_maybe_blank_to_integer(Map.fetch!(map, "timepoint")),
        feed_id: feed_id
      }
    end)
    |> Stream.filter(fn stop_time ->
      MapSet.member?(trip_ids, stop_time.trip_id)
    end)
    |> Stream.chunk_every(500)
    |> Task.async_stream(fn stop_times ->
      {:ok, _} =
        Ecto.Multi.new()
        |> Ecto.Multi.insert_all(:insert_all, StopTime, stop_times)
        |> Repo.transaction()
    end)
    |> Stream.run()

    Ecto.Adapters.SQL.query!(
      Repo,
      """
      update stops SET geom_point = MakePoint("stop_lon", "stop_lat", 4326);
      """
    )

    # Ecto.Adapters.SQL.query!(
    #   Repo,
    #   """
    #   update shapes set geom_point = MakePoint(shape_pt_lon, shape_pt_lat, 4326)
    #   """
    # )

    # Ecto.Adapters.SQL.query!(
    #   Repo,
    #   """
    #   SELECT AsText(  MakeLine((geom_point))),
    #          GLength( MakeLine((geom_point)))
    #   from shapes s where s.shape_id = '23-DEC_66_0_11' limit 1;
    #   """
    # )
  end

  defp convert_string_maybe_blank_to_date(""), do: nil

  defp convert_string_maybe_blank_to_date(string_date) do
    NaiveDateTime.from_iso8601!(string_date)
    |> NaiveDateTime.to_date()
  end

  defp convert_string_maybe_blank_to_integer(""), do: nil

  defp convert_string_maybe_blank_to_integer(string_number) do
    String.to_integer(string_number)
  end

  defp convert_string_maybe_blank_to_float(""), do: nil

  defp convert_string_maybe_blank_to_float(string_number) do
    {float, ""} = Float.parse(string_number)
    float
  end
end
