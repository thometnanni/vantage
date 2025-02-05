defmodule VantageWeb.InvestigationLive.Show do
  use VantageWeb, :live_view

  alias Vantage.Investigations

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket, layout: {VantageWeb.Layouts, :full}}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:investigation, Investigations.get_investigation!(id))}
  end

  defp page_title(:show), do: "Show Investigation"
  defp page_title(:edit), do: "Edit Investigation"
end
