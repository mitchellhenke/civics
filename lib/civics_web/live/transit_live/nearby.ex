defmodule CivicsWeb.TransitLive.Nearby do
  use CivicsWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    socket = assign(socket, :page_title, "Find nearby bus routes")
    {:ok, stream(socket, :assessments, [])}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    address_query = Map.get(params, "address_query", "")
    radius_miles = Map.get(params, "radius_miles", "")

    socket =
      assign(socket, :address_query, address_query)
      |> assign(:radius_miles, radius_miles)

    {:noreply, stream(socket, :routes, [])}
  end
end
