defmodule CivicsWeb.AssessmentLive.Filter do
  @moduledoc """
  Casting and validation for the assessment search filters.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field :address_query, :string, default: ""
    field :min_units, :integer
    field :min_stories, :integer
    field :radius_miles, :float, default: 0.25
    field :near_tax_key, :string, default: ""
  end

  def changeset(filter \\ %__MODULE__{}, attrs) do
    filter
    |> cast(attrs, [:address_query, :min_units, :min_stories, :radius_miles, :near_tax_key])
    |> validate_number(:min_units, greater_than_or_equal_to: 0)
    |> validate_number(:min_stories, greater_than_or_equal_to: 0)
    |> validate_number(:radius_miles, greater_than: 0)
  end
end
