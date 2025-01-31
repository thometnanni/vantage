defmodule VantageWeb.InvestigationLive.Show do
  use VantageWeb, :live_view

  alias ElixirSense.Log
  alias Vantage.{Investigations, Investigations.Investigation}
  require Logger

  @impl true
  def mount(_params, _session, socket) do
    # changeset = Investigations.change_investigation(%Investigation{})
    # {:ok, assign(socket, changeset: changeset)}
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    investigation = Investigations.get_investigation!(id)
    Logger.debug("investigation")
    changeset = Investigations.change_investigation(investigation)
    Logger.debug("changeset")
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:investigation, investigation)
     |> assign(:changeset, to_form(changeset))
    }
  end

  @impl true
  def handle_event("validate", %{"investigation" => investigation_params}, socket) do
    changeset =
      socket.assigns.investigation
      |> Investigations.change_investigation(investigation_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, to_form(changeset))}
  end

  @impl true
  def handle_event("save", %{"investigation" => investigation_params}, socket) do
    case Investigations.update_investigation(socket.assigns.investigation, investigation_params) do
      {:ok, investigation} ->
        changeset = Investigations.change_investigation(%Investigation{})
        {:noreply, socket
        |> assign(:form, to_form(changeset))
        |> assign(:investigation, investigation)
        # |> put_flash(:info, "Investigation updated successfully")
      }

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, socket
        |> put_flash(:error, "fucked up")
        |> assign(:form, to_form(changeset))}
    end
  end

  defp page_title(:show), do: "Show Investigation"
  defp page_title(:edit), do: "Edit Investigation"
end
