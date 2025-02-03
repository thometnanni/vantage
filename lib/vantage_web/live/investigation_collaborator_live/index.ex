defmodule VantageWeb.InvestigationCollaboratorLive.Index do
  use VantageWeb, :live_view

  alias Vantage.Investigations
  alias Vantage.Investigations.InvestigationCollaborator

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :investigation_collaborators, Investigations.list_investigation_collaborators())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Investigation collaborator")
    |> assign(:investigation_collaborator, Investigations.get_investigation_collaborator!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Investigation collaborator")
    |> assign(:investigation_collaborator, %InvestigationCollaborator{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Investigation collaborators")
    |> assign(:investigation_collaborator, nil)
  end

  @impl true
  def handle_info({VantageWeb.InvestigationCollaboratorLive.FormComponent, {:saved, investigation_collaborator}}, socket) do
    {:noreply, stream_insert(socket, :investigation_collaborators, investigation_collaborator)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    investigation_collaborator = Investigations.get_investigation_collaborator!(id)
    {:ok, _} = Investigations.delete_investigation_collaborator(investigation_collaborator)

    {:noreply, stream_delete(socket, :investigation_collaborators, investigation_collaborator)}
  end
end
