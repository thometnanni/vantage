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
  def mount(params, _session, socket) do
    id = params["id"]
    investigation = Investigations.get_investigation!(id)
    models = Models.list_models(id)

    projections =
      Projections.list_projections(id)

    {:ok,
     socket
     |> assign(:investigation, investigation)
     |> assign(:models, models)
     |> assign(:projections, projections), layout: {VantageWeb.Layouts, :full}}
  end

  @impl true
  def handle_params(params, _, socket) do
    model_id = params["model_id"]
    model = (model_id && Models.get_model!(model_id)) || %Model{}
    projection_id = params["projection_id"]
    projection = (projection_id && Projections.get_projection!(projection_id)) || %Projection{}

    live_action = socket.assigns.live_action

    inspector_panel =
      cond do
        live_action in [:models, :models_edit, :models_new] -> :models
        live_action in [:projections, :projections_edit, :projections_new] -> :projections
        live_action == :edit -> :investigation
        true -> nil
      end

    modal_action =
      cond do
        live_action in [:models_edit, :projections_edit] -> :edit
        live_action in [:models_new, :projections_new] -> :new
        true -> nil
      end

    {
      :noreply,
      socket
      |> assign(:page_title, socket.assigns.investigation.name)
      |> assign(:inspector_panel, inspector_panel)
      |> assign(:modal_action, modal_action)
      |> assign(:model_id, model_id)
      |> assign(:model, model)
      |> assign(:projection_id, projection_id)
      |> assign(:projection, projection)
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
  def handle_info({VantageWeb.InvestigationLive.ModalFormComponent, {:saved, projection}}, socket) do
    projections = socket.assigns.projections

    updated_projections =
      projections
      |> Enum.reject(&(&1.id == projection.id))
      |> Enum.concat([projection])

    {:noreply, assign(socket, :projections, updated_projections)}
    # {:noreply, stream_insert(socket, :projections, projection)}
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
         |> put_flash(:error, "Error updating investigation")
         |> assign(:investigation_form, to_form(changeset))}
    end
  end

  def handle_event("vantage:set-focus", %{"id" => id}, socket) do
    {:noreply,
     socket
     |> push_patch(to: ~p"/investigations/#{socket.assigns.investigation.id}/projections/#{id}")}
  end
end
