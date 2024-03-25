defmodule Civics.Transit.Feed do
  use Ecto.Schema
  import Ecto.Changeset

  schema "feeds" do
    field :date, :date
  end

  @doc false
  def changeset(feed, attrs) do
    feed
    |> cast(attrs, [:date])
    |> validate_required([:date])
  end
end
