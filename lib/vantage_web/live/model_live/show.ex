defmodule VantageWeb.ModelLive.Show do
  use VantageWeb, :live_view

  alias Vantage.Models

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id, "investigation_id" => investigation_id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:model, Models.get_model!(id))
     |> assign(:investigation_id, investigation_id)}
  end

  defp page_title(:show), do: "Show Model"
  defp page_title(:edit), do: "Edit Model"
end
