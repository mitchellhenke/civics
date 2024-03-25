defmodule Civics.Transit.Route do
  use Ecto.Schema
  import Ecto.Changeset

  schema "routes" do
    field :route_id, :string
    field :route_short_name, :string
    field :route_long_name, :string
    field :route_desc, :string
    field :route_type, :integer
    field :route_url, :string
    field :route_color, :string
    field :route_text_color, :string
    field :feed_id, :id
  end

  @doc false
  def changeset(route, attrs) do
    route
    |> cast(attrs, [
      :route_id,
      :route_short_name,
      :route_long_name,
      :route_desc,
      :route_type,
      :route_url,
      :route_color,
      :route_text_color
    ])
    |> validate_required([
      :route_id,
      :route_short_name,
      :route_long_name,
      :route_desc,
      :route_type,
      :route_url,
      :route_color,
      :route_text_color
    ])
  end
end
