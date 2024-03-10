defmodule CivicsWeb.AssessmentLive.Show do
  use CivicsWeb, :live_view

  alias Civics.Properties

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:assessment, Properties.get_assessment_by_tax_key!(id))}
  end

  defp page_title(:show), do: "Show Assessment"
  defp page_title(:edit), do: "Edit Assessment"
end
