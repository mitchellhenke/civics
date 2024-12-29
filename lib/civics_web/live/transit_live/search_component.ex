defmodule CivicsWeb.TransitLive.SearchComponent do
  use CivicsWeb, :live_component
  alias Civics.Properties

  @impl true
  def mount(socket) do
    socket =
      assign_new(socket, :assessments, fn -> [] end)
      |> assign_new(:routes, fn -> [] end)
      |> assign_new(:assessment, fn -> nil end)
      |> assign_new(:address_query, fn -> "" end)
      |> assign_new(:radius_miles, fn -> "" end)

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.search_input
        target={@myself}
        event="do-search-address"
        text_value={@address_query}
        name="Address search"
      />
      <.radius_input
        target={@myself}
        event="do-search-radius"
        radius_value={@radius_miles}
        name="Maximum distance (miles)"
      />
      <.results routes={@routes} assessment={@assessment} />
    </div>
    """
  end

  attr :text_value, :string
  attr :name, :string, required: true
  attr :target, :any, required: true
  attr :event, :string, required: true

  def search_input(assigns) do
    ~H"""
    <div>
      <.input
        value={@text_value}
        name={@name}
        label={@name}
        phx-target={@target}
        phx-keyup={@event}
        phx-debounce="100"
        type="text"
        class=""
        aria-expanded="false"
        aria-controls="options"
      />
    </div>
    """
  end

  attr :radius_value, :string
  attr :name, :string, required: true
  attr :target, :any, required: true
  attr :event, :string, required: true

  def radius_input(assigns) do
    ~H"""
    <div>
      <.input
        value={@radius_value}
        name={@name}
        label={@name}
        phx-target={@target}
        phx-keyup={@event}
        phx-debounce="100"
        type="number"
        class=""
        aria-expanded="false"
        aria-controls="options"
      />
    </div>
    """
  end

  attr :routes, :list, required: true
  attr :assessment, :any, required: true

  def results(assigns) do
    ~H"""
    <.header2 :if={@assessment != nil} class="mt-4">
      Routes near <%= Properties.Assessment.address(@assessment) %>
    </.header2>
    <div :if={@routes == []}>
      No Results
    </div>
    <.table id="routes" row_id={&"#{&1.route_id}"} rows={@routes}>
      <:col :let={route} label="Route">
        <%= route.route_id %>
      </:col>
      <:col :let={route} label="Stop">
        <%= route.stop_name %>
      </:col>
      <:col :let={route} label="Distance (miles)">
        <%= format_float(route.distance_meters / 1609) %>
      </:col>
    </.table>
    """
  end

  @impl true
  def update(assigns, socket) do
    assessments = search_assessments(assigns.address_query)

    {routes, assessment} =
      case assessments do
        [assessment | _] ->
          {assessment.geom_point, assigns.radius_miles}
          {search_routes(assessment.geom_point, assigns.radius_miles), assessment}

        [] ->
          {[], nil}
      end

    socket =
      assign(socket, assigns)
      |> assign(
        :assessments,
        assessments
      )
      |> assign(
        :assessment,
        assessment
      )
      |> assign(
        :routes,
        routes
      )

    {:ok, socket}
  end

  @impl true
  def handle_event("do-search-address", %{"value" => value}, socket) do
    params = %{
      address_query: value,
      radius_miles: socket.assigns.radius_miles
    }

    {:noreply,
     socket
     |> push_patch(to: ~p"/transit/nearby?#{params}", replace: true)
     |> assign(:address_query, value)}
  end

  def handle_event("do-search-radius", %{"value" => value}, socket) do
    params = %{
      address_query: socket.assigns.address_query,
      radius_miles: value
    }

    {:noreply,
     socket
     |> push_patch(to: ~p"/transit/nearby?#{params}", replace: true)
     |> assign(:radius_miles, value)}
  end

  defp search_routes(%Geo.Point{} = point, radius_miles) do
    case Float.parse(radius_miles) do
      {miles, ""} ->
        Properties.search_routes(point, miles * 1609)

      _ ->
        []
    end
  end

  defp search_routes(_, _) do
    []
  end

  defp search_assessments(address_query)
       when is_binary(address_query) and byte_size(address_query) > 0 do
    Properties.search_assessments_with_point(address_query)
    |> Enum.take(3)
  end

  defp search_assessments(address_query) when is_binary(address_query) do
    []
  end
end
