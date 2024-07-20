defmodule CivicsWeb.PageJSON do
  @doc """
  Renders a list of geocodes
  """
  def index(%{assessments: assessments}) do
    %{
      data: for(assessment <- assessments, do: data(assessment))
    }
  end

  @doc """
  Renders a single gecode
  """
  def show(%{assessment: assessment}) do
    %{data: data(assessment)}
  end

  defp data(assessment) do
    %{
      address: Civics.Properties.Assessment.address(assessment),
      latitude: assessment.latitude,
      longitude: assessment.longitude
    }
  end
end
