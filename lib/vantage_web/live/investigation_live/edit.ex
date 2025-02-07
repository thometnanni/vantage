defmodule VantageWeb.InvestigationLive.Edit do
  use VantageWeb, :live_view

  require Logger

  alias Vantage.{
    Investigations,
    Investigations.Investigation,
    Models,
    Models.Model,
    Projections,
    Projections.Projection
  }

  @impl true
  def mount(_params, _session, socket) do
    Logger.warning("MOUNT  MOUNT")
    {:ok, socket, layout: {VantageWeb.Layouts, :full}}
  end

  @impl true
  def handle_params(params, _, socket) do
    Logger.warning(inspect(socket.assigns.live_action))
    id = params["id"]
    investigation = Investigations.get_investigation!(id)
    models = Models.list_models(id)
    projections = Projections.list_projections(id)

    {
      :noreply,
      socket
      |> assign(:page_title, investigation.name)
      |> assign(:investigation, investigation)
      |> assign(:models, models)
      |> assign(:projections, projections)
      #  |> apply_action(socket.assigns.live_action, params)
    }
  end

  # defp apply_action(socket, :edit, %{"id" => id}) do
  #   investigation_form = Investigations.change_investigation(socket.assigns.investigation)

  #   socket
  #   |> assign(:investigation_form, to_form(investigation_form))
  # end

  # defp apply_action(socket, :models, %{"id" => id}) do
  #   models = Models.list_models(id)
  #   Logger.warning("models: #{inspect(models)}")

  #   socket
  #   |> assign(:models, models)
  # end

  # defp apply_action(socket, _, %{"id" => id}) do
  #   # do nothing
  #   socket
  # end

  @impl true
  def handle_info(
        {VantageWeb.InvestigationLive.FormInvestigation, {:saved, investigation}},
        socket
      ) do
    {:noreply,
     socket
     |> assign(:investigation, investigation)
     |> assign(:page_title, investigation.name)}
  end

  @impl true
  def handle_event("save", %{"investigation" => investigation_params}, socket) do
    Logger.warning("investigation in edit")

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
