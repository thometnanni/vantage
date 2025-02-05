defmodule VantageWeb.InvestigationLive.Show do
  use VantageWeb, :live_view

  alias Vantage.Investigations

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket, layout: {VantageWeb.Layouts, :full}}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    investigation = Investigations.get_investigation!(id)

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action, investigation.name))
     |> assign(:header_title, page_title(socket.assigns.live_action, investigation.name))
     |> assign(:investigation, investigation)}
  end

  defp page_title(:show, name), do: name
  defp page_title(:edit, name), do: "Edit #{name}"
end
