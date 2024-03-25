defmodule Civics.Transit.CalendarDate do
  use Ecto.Schema
  import Ecto.Changeset

  schema "calendar_dates" do
    field :date, :date
    field :service_id, :string
    field :exception_type, :integer
    field :feed_id, :id
  end

  @doc false
  def changeset(calendar_date, attrs) do
    calendar_date
    |> cast(attrs, [:service_id, :date, :exception_type])
    |> validate_required([:service_id, :date, :exception_type])
  end
end
