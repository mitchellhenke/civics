defmodule Civics.Properties.AssessmentFts do
  use Ecto.Schema
  alias Civics.Properties

  @timestamps_opts false
  @primary_key {:id, :id, autogenerate: true, source: :rowid}
  schema "assessments_fts" do
    field :tax_key, :string
    field :full_address, :string
    field :rank, :float, virtual: true

    belongs_to :assessment, Properties.Assessment,
      foreign_key: :tax_key,
      references: :tax_key,
      define_field: false
  end
end
