defmodule Civics.Repo.Migrations.CreateAssessments do
  use Ecto.Migration

  def change do
    create table(:assessments) do
      add :tax_key, :string
      add :tax_rate_cd, :integer
      add :house_number_high, :integer
      add :house_number_low, :integer
      add :house_number_suffix, :string
      add :street_direction, :string
      add :street, :string
      add :street_type, :string
      add :year, :integer
      add :assessed_land, :integer
      add :assessed_improvements, :integer
      add :assessed_total, :integer
      add :assessed_land_exempt, :integer
      add :assessed_improvements_exempt, :integer
      add :assessed_total_exempt, :integer
      add :exemption_code, :string
      add :building_area, :float
      add :year_built, :integer
      add :number_of_bedrooms, :integer
      add :number_of_bathrooms, :integer
      add :number_of_powder_rooms, :integer
      add :lot_area, :float
      add :zoning, :string
      add :building_type, :string
      add :zip_code, :string
      add :land_use, :string
      add :land_use_general, :string
      add :fireplace, :integer
      add :air_conditioning, :integer
      add :parking_type, :string
      add :number_units, :integer
      add :number_stories, :float
      add :attic, :string
      add :basement, :string
      add :neighborhood, :string
      add :tract, :string
      add :block, :string
      add :alder, :string
      add :convey_date, :date
      add :convey_type, :string
      add :owner_name_1, :string
      add :owner_name_2, :string
      add :owner_name_3, :string
      add :owner_mail_address, :string
      add :owner_city_state, :string
      add :owner_zip_code, :string
      add :owner_occupied, :boolean, default: false, null: false

      timestamps(type: :utc_datetime)
    end

    create(index(:assessments, [:tax_key], unique: true))

    execute(
      """
      CREATE VIRTUAL TABLE assessments_fts USING fts5(
        tax_key UNINDEXED,
        full_address,
        tokenize="trigram"
      );
      """,
      """
      DROP TABLE assessments_fts;
      """
    )

    create table(:assessment_shapefiles) do
      add :tax_key, :string
    end

    execute(
      """
      SELECT InitSpatialMetaData();
      """,
      """
      """
    )

    execute(
      """
      SELECT AddGeometryColumn('assessment_shapefiles', 'geom', 4326, 'MULTIPOLYGON');
      """,
      """
      """
    )

    execute(
      """
      SELECT AddGeometryColumn('assessment_shapefiles', 'geom_point', 4326, 'POINT');
      """,
      """
      """
    )
  end
end

# .load /opt/homebrew/lib/mod_spatialite.dylib
