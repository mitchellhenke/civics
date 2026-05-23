defmodule CivicsWeb.AssessmentLive.Index do
  use CivicsWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    socket = assign(socket, :page_title, "Listing Assessments")
    {:ok, stream(socket, :assessments, [])}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    socket =
      socket
      |> assign(:address_query, Map.get(params, "address_query", ""))
      |> assign(:min_units, Map.get(params, "min_units", ""))
      |> assign(:min_stories, Map.get(params, "min_stories", ""))
      |> assign(:near_tax_key, Map.get(params, "near_tax_key", ""))
      |> assign(:radius_miles, Map.get(params, "radius_miles", "0.25"))

    {:noreply, stream(socket, :assessments, [])}
  end
end
