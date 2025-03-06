defmodule Civics.Geo.Neighborhood do
  use Ecto.Schema
  import Ecto.Changeset

  schema "neighborhoods" do
    field(:name, :string)
    field(:geom, GeoSpatialite.Geometry)
  end

  @doc false
  def changeset(assessment_shapefile, attrs) do
    assessment_shapefile
    |> cast(attrs, [
      :name,
      :geom
    ])
    |> validate_required([
      :name
    ])
  end

  # def list(x_min, y_min, x_max, y_max, zoning) do
  #   query =
  #     from(s in "mitchells_material_view",
  #       where:
  #         fragment("? && ST_MakeEnvelope(?, ?, ?, ?)", s.geom, ^x_min, ^y_min, ^x_max, ^y_max) and
  #           s.nonunique_plot == 0,
  #       select: %{
  #         geo_json: s.geo_json,
  #         assessment: %{
  #           last_assessment_land: s.last_assessment_land,
  #           lot_area: s.lot_area,
  #           tax_key: s.tax_key,
  #           zoning: s.zoning
  #         }
  #       },
  #       limit: 1000
  #     )

  #   query =
  #     if is_nil(zoning) || zoning == "" do
  #       query
  #     else
  #       from(s in query, where: s.zoning == ^zoning)
  #     end

  #   Properties.Repo.all(query)
  # end

  # def list_shapefiles_with_change_in_absolute_assessment(x_min, y_min, x_max, y_max) do
  #   from(s in "change_in_assessment_material_view",
  #     where: fragment("? && ST_MakeEnvelope(?, ?, ?, ?)", s.geom, ^x_min, ^y_min, ^x_max, ^y_max),
  #     select: %{
  #       geo_json: s.geo_json,
  #       assessment: %{
  #         assessment_2018: s."2018_total",
  #         assessment_2019: s."2019_total",
  #         absolute_change: s.absolute_assessment_change
  #       }
  #     }
  #   )
  #   |> Properties.Repo.all()
  # end

  # def list_shapefiles_with_change_in_percent_assessment(x_min, y_min, x_max, y_max) do
  #   from(s in "change_in_assessment_material_view",
  #     where: fragment("? && ST_MakeEnvelope(?, ?, ?, ?)", s.geom, ^x_min, ^y_min, ^x_max, ^y_max),
  #     select: %{
  #       geo_json: s.geo_json,
  #       assessment: %{
  #         tax_key: s.tax_key,
  #         assessment_2018: s."2018_total",
  #         assessment_2019: s."2019_total",
  #         percent_change: s.percent_assessment_change
  #       }
  #     }
  #   )
  #   |> Properties.Repo.all()
  # end

  # def get_by_tax_key(tax_key) do
  #   results = from(s in Properties.ShapeFile, where: s.taxkey == ^tax_key, limit: 1)

  #   case Properties.Repo.all(results) do
  #     [] -> nil
  #     [result] -> result
  #   end
  # end
end

# alias Civics.Properties.AssessmentShapefile

# as =
#   AssessmentShapefile.changeset(
#     %AssessmentShapefile{},
#     %{tax_key: "ABC", geom: %Geo.MultiPolygon{coordinates: [[[{75, 29}], [{75, 29}, {77, 29}, {77, 29}, {75, 29}]]], srid: 4326}}
#   )

# Civics.Repo.insert(as)

# import Ecto.Query
# alias Civics.Properties.AssessmentShapefile
# from(s in AssessmentShapefile) |> Civics.Repo.all()

# "0020000001000010E600000000000000000000000000000000"
# <<0, 32, 0, 0, 1, 0, 0, 16, 230, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0>>
# s = %Geo.Point{coordinates: {45000.6969, 45}, srid: 4326}
# s = %Geo.LineString{coordinates: [{45, 45}, {50, 50}], srid: 4326}
# s = %Geo.Polygon{coordinates: [[{75, 29}], [{75, 29}, {77, 29}, {77, 29}, {75, 29}]], srid: 4326}
# s = %Geo.MultiPolygon{coordinates: [[[{75, 29}], [{75, 29}, {77, 29}, {77, 29}, {75, 29}]]], srid: 4326}

# Civics.Sqlite.Encoder.encode!(s) |> IO.iodata_to_binary() |> IO.inspect(limit: :infinity) |> Civics.Sqlite.decode

# [[{0, 45}, {50, -50}], [{45, 45}, {50, 50}]]

# "0001E61000000000000000C052400000000000003D4000000000004053400000000000003D407C0300000001000000040000000000000000C052400000000000003D4000000000004053400000000000003D4000000000004053400000000000003D400000000000C052400000000000003D40FE" == "0001E61000000000000000C052400000000000003D4000000000004053400000000000003D407C0300000001000000040000000000000000C052400000000000003D4000000000004053400000000000003D4000000000004053400000000000003D400000000000C052400000000000003D40FE"

# "0001E610000000000000008046400000000000804640000000000080464000000000000049407C02000000020000000000000000804640000000000080464000000000008046400000000000004940FE"

# "0001E610000041DC619815FB55C0A05B3F91388545403A57E1D6D1FA55C0053FC5F4638545407C060000000200000069030000000100000017000000A5441F32F9FA55C0C9CB8203638545408A22DB18E8FA55C06CFB03636285454048006948E7FA55C0FA1E705C62854540B3792079E7FA55C040E2BFDB3F8545405AA8AE08F3FA55C038A10011408545402F718204F3FA55C06DDB23D442854540422E5B4CF9FA55C0813CBE0543854540F898E54DF9FA55C0254F16AB42854540440DB3AFFDFA55C01BCDD8BF428545405B40841802FB55C0E0E11F51408545407C08F64506FB55C0DE3775003E8545402167C01310FB55C0A05B3F9138854540E8E1581010FB55C0C08FC5AC39854540317A310110FB55C0730CFC7C40854540E58635CC12FB55C08EA9807D4085454041DC619815FB55C00A0CAD8F4085454059810B5415FB55C0DF84DCA863854540681BB05315FB55C0053FC5F4638545402E51C56112FB55C00EF27CEC6385454075AC07DD0FFB55C0AE5090E863854540861C59BB0CFB55C0BC9597C96385454080750671FDFA55C01A32623263854540A5441F32F9FA55C0C9CB820363854540690300000001000000050000006D52DF1DD2FA55C0E47657CE3F8545403E22ED9AE2FA55C09F4680FB3F8545408798D380E2FA55C0434AEC2D628545403A57E1D6D1FA55C0388C1785618545406D52DF1DD2FA55C0E47657CE3F854540FE" ==
# "0001E610000041DC619815FB55C0A05B3F91388545403A57E1D6D1FA55C0053FC5F4638545407C060000000200000069030000000100000017000000A5441F32F9FA55C0C9CB8203638545408A22DB18E8FA55C06CFB03636285454048006948E7FA55C0FA1E705C62854540B3792079E7FA55C040E2BFDB3F8545405AA8AE08F3FA55C038A10011408545402F718204F3FA55C06DDB23D442854540422E5B4CF9FA55C0813CBE0543854540F898E54DF9FA55C0254F16AB42854540440DB3AFFDFA55C01BCDD8BF428545405B40841802FB55C0E0E11F51408545407C08F64506FB55C0DE3775003E8545402167C01310FB55C0A05B3F9138854540E8E1581010FB55C0C08FC5AC39854540317A310110FB55C0730CFC7C40854540E58635CC12FB55C08EA9807D4085454041DC619815FB55C00A0CAD8F4085454059810B5415FB55C0DF84DCA863854540681BB05315FB55C0053FC5F4638545402E51C56112FB55C00EF27CEC6385454075AC07DD0FFB55C0AE5090E863854540861C59BB0CFB55C0BC9597C96385454080750671FDFA55C01A32623263854540A5441F32F9FA55C0C9CB820363854540690300000001000000050000006D52DF1DD2FA55C0E47657CE3F8545403E22ED9AE2FA55C09F4680FB3F8545408798D380E2FA55C0434AEC2D628545403A57E1D6D1FA55C0388C1785618545406D52DF1DD2FA55C0E47657CE3F854540FE"
