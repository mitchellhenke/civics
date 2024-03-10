defmodule CivicsWeb.AssessmentLive.Index do
  use CivicsWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    socket = assign(socket, :page_title, "Listing Assessments")
    {:ok, stream(socket, :assessments, [])}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    address_query = Map.get(params, "address_query", "")

    socket =
      assign(socket, :address_query, address_query)

    {:noreply, stream(socket, :assessments, [])}
  end
end
