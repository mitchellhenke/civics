defmodule CivicsWeb.AssessmentLive.SearchComponent do
  use CivicsWeb, :live_component
  alias Civics.Properties
  alias CivicsWeb.AssessmentLive.Filter

  @meters_per_mile 1609

  @impl true
  def mount(socket) do
    socket =
      assign_new(socket, :assessments, fn -> [] end)
      |> assign_new(:address_query, fn -> "" end)
      |> assign_new(:min_units, fn -> "" end)
      |> assign_new(:min_stories, fn -> "" end)
      |> assign_new(:near_tax_key, fn -> "" end)
      |> assign_new(:radius_miles, fn -> "0.25" end)

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.form for={@form} phx-target={@myself} phx-change="do-filter">
        <.input
          field={@form[:address_query]}
          type="text"
          label="Address"
          phx-debounce="100"
          aria-expanded="false"
          aria-controls="options"
        />
        <.input
          field={@form[:min_units]}
          type="number"
          label="Minimum units"
          min="0"
          phx-debounce="300"
        />
        <.input
          field={@form[:min_stories]}
          type="number"
          label="Minimum stories"
          min="0"
          phx-debounce="300"
        />
        <.input
          :if={@near_tax_key != ""}
          field={@form[:radius_miles]}
          type="number"
          label="Radius (miles)"
          min="0"
          step="0.1"
          phx-debounce="300"
        />
      </.form>
      <.results assessments={@assessments} target={@myself} near_tax_key={@near_tax_key} />
    </div>
    """
  end

  attr :assessments, :list, required: true
  attr :target, :any, required: true
  attr :near_tax_key, :string, required: true

  def results(assigns) do
    ~H"""
    <div :if={@near_tax_key != ""} class="mt-4 flex items-center gap-3">
      <span>Showing assessments near the selected property.</span>
      <.button type="button" phx-target={@target} phx-click="clear-near" class="text-xs">
        Clear
      </.button>
    </div>
    <div :if={@assessments == []} id="option-none">
      No Results
    </div>
    <.keyed_table id="assessments" row_id={&"#{&1.id}"} rows={@assessments}>
      <:col :let={assessment} label="Address">
        <.good_link navigate={~p"/assessments/#{assessment.tax_key}"}>
          {Civics.Properties.Assessment.address(assessment)}
        </.good_link>
      </:col>
      <:col :let={assessment} label="Bedrooms" class="hidden sm:table-cell">
        {assessment.number_of_bedrooms}
      </:col>
      <:col :let={assessment} label="Bathrooms" class="hidden sm:table-cell">
        {Properties.Assessment.bathroom_count(assessment)}
      </:col>
      <:col :let={assessment} label="Lot Area (sq ft)" class="hidden sm:table-cell">
        {format_int(assessment.lot_area)}
      </:col>
      <:col :let={assessment} label="Building Area (sq ft)" class="hidden sm:table-cell">
        {format_int(assessment.building_area)}
      </:col>
      <:col :let={assessment} label="Zoning" class="hidden sm:table-cell">
        {assessment.zoning}
      </:col>
      <:col :let={assessment} label="Units" class="hidden sm:table-cell">
        {assessment.number_units}
      </:col>
      <:col :let={assessment} label="Stories" class="hidden sm:table-cell">
        {assessment.number_stories}
      </:col>
      <:col :let={property} label="Assessed Value" class="hidden md:table-cell">
        ${format_dollars(property.assessed_total)}
      </:col>
      <:action :let={assessment}>
        <.button
          type="button"
          phx-target={@target}
          phx-click="near-here"
          phx-value-tax_key={assessment.tax_key}
          class="text-xs"
        >
          Near Here
        </.button>
      </:action>
    </.keyed_table>
    """
  end

  @impl true
  def update(assigns, socket) do
    socket = assign(socket, assigns)

    changeset =
      Filter.changeset(%Filter{}, %{
        "address_query" => socket.assigns.address_query,
        "min_units" => socket.assigns.min_units,
        "min_stories" => socket.assigns.min_stories,
        "radius_miles" => socket.assigns.radius_miles,
        "near_tax_key" => socket.assigns.near_tax_key
      })

    filter = Ecto.Changeset.apply_changes(changeset)

    {:ok,
     socket
     |> assign(:filter, filter)
     |> assign(:assessments, search_assessments(filter))
     |> assign(:form, to_form(changeset, as: :filter))}
  end

  @impl true
  def handle_event("do-filter", %{"filter" => params}, socket) do
    current = socket.assigns.filter

    # Searching a new address exits "near here" mode.
    near_tax_key =
      if Map.get(params, "address_query", current.address_query) != current.address_query do
        ""
      else
        current.near_tax_key
      end

    params = Map.put(params, "near_tax_key", near_tax_key)
    changeset = %{Filter.changeset(current, params) | action: :validate}

    if changeset.valid? do
      {:noreply, patch(socket, Ecto.Changeset.apply_changes(changeset))}
    else
      {:noreply, assign(socket, :form, to_form(changeset, as: :filter))}
    end
  end

  def handle_event("near-here", %{"tax_key" => tax_key}, socket) do
    {:noreply, patch(socket, %{socket.assigns.filter | near_tax_key: tax_key})}
  end

  def handle_event("clear-near", _params, socket) do
    {:noreply, patch(socket, %{socket.assigns.filter | near_tax_key: ""})}
  end

  defp patch(socket, %Filter{} = filter) do
    base = %{
      address_query: filter.address_query,
      min_units: filter.min_units,
      min_stories: filter.min_stories,
      near_tax_key: filter.near_tax_key
    }

    params =
      if filter.near_tax_key not in [nil, ""] do
        Map.put(base, :radius_miles, filter.radius_miles)
      else
        base
      end
      |> Enum.reject(fn {_key, value} -> value in [nil, ""] end)
      |> Map.new()

    push_patch(socket, to: ~p"/assessments?#{params}", replace: true)
  end

  defp search_assessments(%Filter{near_tax_key: tax_key} = filter)
       when is_binary(tax_key) and tax_key != "" do
    radius_m = filter.radius_miles * @meters_per_mile
    Properties.assessments_near(tax_key, radius_m, min_opts(filter))
  end

  defp search_assessments(%Filter{} = filter) do
    Properties.search_assessments(filter.address_query, min_opts(filter))
  end

  defp min_opts(%Filter{} = filter) do
    [min_units: filter.min_units, min_stories: filter.min_stories]
  end
end
