defmodule CivicsWeb.AssessmentLive.SearchComponent do
  use CivicsWeb, :live_component
  alias Civics.Properties

  @impl true
  def mount(socket) do
    socket =
      assign_new(socket, :assessments, fn -> [] end)
      |> assign_new(:address_query, fn -> "" end)

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
        name="Address"
      />
      <.results assessments={@assessments} />
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

  attr :assessments, :list, required: true

  def results(assigns) do
    ~H"""
    <div :if={@assessments == []} id="option-none">
      No Results
    </div>
    <.table id="assessments" row_id={&"#{&1.id}"} rows={@assessments}>
      <:col :let={assessment} label="Address">
        <.good_link navigate={~p"/assessments/#{assessment.tax_key}"}>
          <%= Civics.Properties.Assessment.address(assessment) %>
        </.good_link>
      </:col>
      <:col :let={assessment} label="Bedrooms" class="hidden sm:table-cell">
        <%= assessment.number_of_bedrooms %>
      </:col>
      <:col :let={assessment} label="Bathrooms" class="hidden sm:table-cell">
        <%= Properties.Assessment.bathroom_count(assessment) %>
      </:col>
      <:col :let={assessment} label="Lot Area" class="hidden sm:table-cell">
        <%= assessment.lot_area %>
      </:col>
      <:col :let={assessment} label="Building Area" class="hidden sm:table-cell">
        <%= assessment.building_area %>
      </:col>
      <:col :let={assessment} label="Zoning" class="hidden sm:table-cell">
        <%= assessment.zoning %>
      </:col>
      <:col :let={property} label="Assessed Value" class="hidden md:table-cell">
        $<%= format_dollars(property.assessed_total) %>
      </:col>
    </.table>
    """
  end

  @impl true
  def update(assigns, socket) do
    socket =
      assign(socket, assigns)
      |> assign(
        :assessments,
        search_assessments(assigns.address_query)
      )

    {:ok, socket}
  end

  @impl true
  def handle_event("do-search-address", %{"value" => value}, socket) do
    params = %{
      address_query: value
    }

    {:noreply,
     socket
     |> push_patch(to: ~p"/assessments?#{params}")
     |> assign(:address_query, value)}
  end

  defp search_assessments(address_query) when is_binary(address_query) do
    Civics.Properties.search_assessments(address_query)
  end
end
