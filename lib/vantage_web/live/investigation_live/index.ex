defmodule VantageWeb.InvestigationLive.Index do
  use VantageWeb, :live_view

  alias Vantage.Investigations
  alias Vantage.Investigations.Investigation

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :investigations, Investigations.list_investigations())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Investigation")
    |> assign(:investigation, Investigations.get_investigation!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Investigation")
    |> assign(:investigation, %Investigation{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Investigations")
    |> assign(:investigation, nil)
  end

  @impl true
  def handle_info({VantageWeb.InvestigationLive.FormComponent, {:saved, investigation}}, socket) do
    {:noreply, stream_insert(socket, :investigations, investigation)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    investigation = Investigations.get_investigation!(id)
    {:ok, _} = Investigations.delete_investigation(investigation)

    {:noreply, stream_delete(socket, :investigations, investigation)}
  end
end
