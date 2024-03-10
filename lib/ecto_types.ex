defmodule Civics.EctoTypes do
  defmodule Geometry do
    use Ecto.Type

    @geometries [
      Geo.Point,
      Geo.LineString,
      Geo.Polygon,
      Geo.MultiPolygon
    ]

    def type, do: :binary

    def cast(%struct{} = geom) when struct in @geometries, do: {:ok, geom}
    def cast(_), do: :error

    def load(data) when is_binary(data) do
      case Civics.Sqlite.decode(data) do
        :error ->
          :error

        geo ->
          {:ok, geo}
      end
    end

    def dump(%struct{} = geom) when struct in @geometries do
      Civics.Sqlite.encode(geom)
    end

    def dump(_), do: :error
  end
end
