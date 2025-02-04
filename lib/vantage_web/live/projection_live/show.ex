defmodule VantageWeb.ProjectionLive.Show do
  use VantageWeb, :live_view

  alias Vantage.Projections

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id, "investigation_id" => investigation_id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:projection, Projections.get_projection!(id))
     |> assign(:investigation_id, investigation_id)}
  end

  defp page_title(:show), do: "Show Projection"
  defp page_title(:edit), do: "Edit Projection"
end
