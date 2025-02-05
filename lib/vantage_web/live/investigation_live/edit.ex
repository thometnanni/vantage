defmodule VantageWeb.InvestigationLive.Edit do
  use VantageWeb, :live_view

  require Logger
  alias Vantage.{Investigations, Investigations.Investigation}

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket, layout: {VantageWeb.Layouts, :full}}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    investigation = Investigations.get_investigation!(id)
    investigation_form = Investigations.change_investigation(investigation)

    {:noreply,
     socket
     |> assign(:page_title, investigation.name)
     |> assign(:investigation, investigation)
     |> assign(:investigation_form, to_form(investigation_form))}
  end

  @impl true
  def handle_event("validate", %{"investigation" => investigation_params}, socket) do
    changeset =
      socket.assigns.investigation
      |> Investigations.change_investigation(investigation_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :investigation_form, to_form(changeset))}
  end

  @impl true
  def handle_event("save", %{"investigation" => investigation_params}, socket) do
    case Investigations.update_investigation(socket.assigns.investigation, investigation_params) do
      {:ok, investigation} ->
        changeset = Investigations.change_investigation(%Investigation{})

        {
          :noreply,
          socket
          |> assign(:investigation_form, to_form(changeset))
          |> assign(:investigation, investigation)
          |> assign(:page_title, investigation.name)
          # |> put_flash(:info, "Investigation updated successfully")
        }

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply,
         socket
         |> put_flash(:error, "fucked up")
         |> assign(:investigation_form, to_form(changeset))}
    end
  end
end
