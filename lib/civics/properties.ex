defmodule Civics.Properties do
  @moduledoc """
  The Properties context.
  """

  import Ecto.Query, warn: false
  alias Civics.Repo

  alias Civics.Properties.{Assessment, AssessmentFts, AssessmentShapefile}

  @doc """
  Returns the list of assessments.

  ## Examples

      iex> list_assessments()
      [%Assessment{}, ...]

  """
  def list_assessments do
    Repo.all(Assessment)
  end

  @doc """
  Gets a single assessment.

  Raises `Ecto.NoResultsError` if the Assessment does not exist.

  ## Examples

      iex> get_assessment!(123)
      %Assessment{}

      iex> get_assessment!(456)
      ** (Ecto.NoResultsError)

  """
  def get_assessment!(id), do: Repo.get!(Assessment, id)
  def get_assessment_by_tax_key!(tax_key), do: Repo.get_by!(Assessment, tax_key: tax_key)

  def search_assessments(address_query) do
    formatted_query = format_query(address_query)

    query =
      from(a in Assessment,
        limit: 100
      )

    if address_query == "" do
      from(a in query,
        order_by: [desc: a.assessed_total]
      )
    else
      from(a in query,
        where: fragment("full_address LIKE ?", ^formatted_query),
        join: af in AssessmentFts,
        on: af.tax_key == a.tax_key,
        select: a,
        order_by: [asc: af.rank]
      )
    end
    |> Repo.all()
  end

  def assessments_within(point, radius_in_m) do
    point = point || %Geo.Point{coordinates: {-87.9072378, 43.0380655}, srid: 4326}
    {lng, lat} = point.coordinates

    query =
      from(a in Assessment,
        join: as in AssessmentShapefile,
        on: as.tax_key == a.tax_key,
        select: %{a | geom_point: as.geom_point},
        where:
          fragment(
            "PtDistWithin(?, MakePoint(?, ?, ?), ?)",
            as.geom_point,
            ^lng,
            ^lat,
            ^point.srid,
            ^radius_in_m
          ),
        where:
          fragment(
            """
            ? IN (
              SELECT rowid
              FROM SpatialIndex
              WHERE f_table_name = 'assessment_shapefiles'
              and f_geometry_column = 'geom_point'
              AND search_frame = ST_Expand(MakePoint(?, ?, ?), ?)
            )
            """,
            field(as, :rowid),
            ^lng,
            ^lat,
            ^point.srid,
            ^(radius_in_m / 111_000)
          ),
        limit: 100
      )

    Repo.all(query)
  end

  def search_assessments_with_point(address_query) do
    formatted_query = format_query(address_query)

    query =
      from(a in Assessment,
        limit: 10
      )

    if address_query == "" do
      from(a in query,
        order_by: [desc: a.assessed_total]
      )
    else
      from(a in query,
        where: fragment("full_address LIKE ?", ^formatted_query),
        join: af in AssessmentFts,
        on: af.tax_key == a.tax_key,
        join: s in AssessmentShapefile,
        on: s.tax_key == a.tax_key,
        select: %{a | geom_point: s.geom_point},
        order_by: [asc: af.rank]
      )
    end
    |> Repo.all()
  end

  def search_routes(point, distance_meters \\ 800, date_time \\ nil) do
    # point = %Geo.Point{coordinates: {-88.0277474, 43.0750766}, srid: 4326}
    {latitude, longitude} = point.coordinates
    date_time = date_time || DateTime.utc_now()
    date = DateTime.to_date(date_time)
    interval = time_to_seconds(date_time)

    """
      select DISTINCT(t.route_id), s.stop_name, s.geom_point, s.stop_id, round(111000 * (abs(ST_X(s.geom_point) - #{latitude}) + abs(ST_Y(s.geom_point) - #{longitude}))) as manhattan_meters, round(111000 * min(Distance(s.geom_point, MakePoint(#{latitude}, #{longitude}, #{point.srid})))) as distance_meters
        from stops s
      JOIN stop_times st on st.stop_id = s.stop_id
      JOIN trips t on t.trip_id = st.trip_id
      JOIN calendar_dates cd on cd.service_id = t.service_id
      WHERE cd.date = '#{date}' AND st.arrival_time > #{interval} AND PtDistWithin(s.geom_point, MakePoint(#{latitude}, #{longitude}, #{point.srid}), #{distance_meters}) AND s.rowid IN (
            SELECT rowid
            FROM SpatialIndex
            WHERE f_table_name = 'stops'
            and f_geometry_column = 'geom_point'
            AND search_frame = ST_Expand(MakePoint(#{latitude}, #{longitude}, #{point.srid}), #{distance_meters / 111_000})
      )
        group by t.route_id
        order by distance_meters asc;
    """
    |> IO.puts()

    {:ok, result} =
      Repo.query(
        """
        select DISTINCT(t.route_id), s.stop_name, s.geom_point, s.stop_id, round(111000 * (abs(ST_X(s.geom_point) - ?) + abs(ST_Y(s.geom_point) - ?))) as manhattan_meters, round(111000 * min(Distance(s.geom_point, MakePoint(?, ?, ?)))) as distance_meters
          from stops s
        JOIN stop_times st on st.stop_id = s.stop_id
        JOIN trips t on t.trip_id = st.trip_id
        JOIN calendar_dates cd on cd.service_id = t.service_id
        WHERE cd.date = ? AND st.arrival_time > ? AND PtDistWithin(s.geom_point, MakePoint(?, ?, ?), ?) AND s.rowid IN (
              SELECT rowid
              FROM SpatialIndex
              WHERE f_table_name = 'stops'
              and f_geometry_column = 'geom_point'
              AND search_frame = ST_Expand(MakePoint(?, ?, ?), ?)
        )
          group by t.route_id
          order by distance_meters asc;
        """,
        [
          latitude,
          longitude,
          latitude,
          longitude,
          point.srid,
          date,
          interval,
          latitude,
          longitude,
          point.srid,
          distance_meters,
          latitude,
          longitude,
          point.srid,
          distance_meters / 111_000
        ]
      )

    columns = Enum.map(result.columns, &String.to_atom(&1))

    Enum.map(result.rows, fn row ->
      result =
        Enum.zip(columns, row)
        |> Enum.into(%{})

      if result.geom_point do
        Map.put(result, :geom_point, Civics.Sqlite.decode!(result.geom_point))
      else
        result
      end
    end)
  end

  defp time_to_seconds(%{hour: h, minute: m, second: s}) do
    60 * 60 * h + 60 * m + s
  end

  defp format_query(query) do
    q =
      String.split(query, " ")
      |> Enum.join("%")

    "%#{q}%"
  end
end
