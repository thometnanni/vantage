defmodule VantageWeb.InvestigationLive.Edit do
  use VantageWeb, :live_view

  require Logger

  alias Vantage.{
    Investigations,
    Investigations.Investigation,
    Models,
    Models.Model,
    Projections,
    Projections.Projection,
    Keyframes
  }

  @impl true
  def mount(params, _session, socket) do
    id = params["id"]
    investigation = Investigations.get_investigation!(id)
    models = Models.list_models(id)

    projections =
      Projections.list_projections_with_keyframes(id)

    # Logger.warning(inspect(projections))

    {:ok,
     socket
     |> assign(:investigation, investigation)
     |> assign(:models, models)
     |> assign(:first_person, false)
     |> assign(:time, 0.0)
     |> assign(:projections, projections), layout: {VantageWeb.Layouts, :full}}
  end

  @impl true
  def handle_params(params, _, socket) do
    model_id = params["model_id"]
    model = (model_id && Models.get_model!(model_id)) || %Model{}
    projection_id = params["projection_id"]

    projection =
      (projection_id && Projections.get_projection_with_keyframes!(projection_id)) ||
        %Projection{}

    live_action = socket.assigns.live_action

    panel_action =
      cond do
        live_action in [:models, :model, :model_edit, :model_new] ->
          :models

        live_action in [:projections, :projection, :projection_edit, :projection_new] ->
          :projections

        live_action == :edit ->
          :investigation

        true ->
          nil
      end

    type =
      cond do
        live_action in [:model, :model_edit, :model_new] -> :model
        live_action in [:projection, :projection_edit, :projection_new] -> :projection
        true -> nil
      end

    modal_action =
      cond do
        live_action in [:model_edit, :projection_edit] -> :edit
        live_action in [:model_new, :projection_new] -> :new
        true -> nil
      end

    {
      :noreply,
      socket
      |> assign(:page_title, socket.assigns.investigation.name)
      |> assign(:type, type)
      |> assign(:modal_action, modal_action)
      |> assign(:panel_action, panel_action)
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
  def handle_info(
        {VantageWeb.InvestigationLive.ProjectionInspector, {:saved, projection}},
        socket
      ) do
    # projection = Projections.get_projection_with_keyframes!(keyframe.projection_id)

    projections = socket.assigns.projections

    updated_projections =
      if Enum.any?(projections, &(&1.id == projection.id)) do
        projections
        |> Enum.map(fn p -> if p.id == projection.id, do: projection, else: p end)
      else
        projections ++ [projection]
      end

    {:noreply,
     socket
     |> assign(:projection, projection)
     |> assign(:projections, updated_projections)}
  end

  @impl true
  def handle_info(
        {VantageWeb.InvestigationLive.ProjectionInspector, {:saved_keyframe, keyframe}},
        socket
      ) do
    projection = Projections.get_projection_with_keyframes!(keyframe.projection_id)

    projections = socket.assigns.projections

    updated_projections =
      if Enum.any?(projections, &(&1.id == projection.id)) do
        projections
        |> Enum.map(fn p -> if p.id == projection.id, do: projection, else: p end)
      else
        projections ++ [projection]
      end

    {:noreply,
     socket
     |> assign(:projection, projection)
     |> assign(:projections, updated_projections)}
  end

  @impl true
  def handle_info(
        {VantageWeb.InvestigationLive.ModalFormComponent, {:saved_projection, projection}},
        socket
      ) do
    projection = Projections.get_projection_with_keyframes!(projection.id)
    projections = socket.assigns.projections

    updated_projections =
      if Enum.any?(projections, &(&1.id == projection.id)) do
        projections
        |> Enum.map(fn p -> if p.id == projection.id, do: projection, else: p end)
      else
        projections ++ [projection]
      end

    {:noreply, assign(socket, :projections, updated_projections)}
  end

  @impl true
  def handle_info(
        {VantageWeb.InvestigationLive.ModalFormComponent, {:saved_model, model}},
        socket
      ) do
    models = socket.assigns.models

    updated_models =
      if Enum.any?(models, &(&1.id == model.id)) do
        models
        |> Enum.map(fn p -> if p.id == model.id, do: model, else: p end)
      else
        models ++ [model]
      end

    {:noreply, assign(socket, :models, updated_models)}
  end

  @impl true
  def handle_info(
        {VantageWeb.InvestigationLive.ModalFormComponent, {:deleted_projection, projection}},
        socket
      ) do
    projections = Enum.reject(socket.assigns.projections, fn p -> p.id == projection.id end)
    {:noreply, assign(socket, :projections, projections)}
  end

  @impl true
  def handle_info(
        {VantageWeb.InvestigationLive.ModalFormComponent, {:deleted_model, model}},
        socket
      ) do
    models = Enum.reject(socket.assigns.models, fn p -> p.id == model.id end)
    {:noreply, assign(socket, :models, models)}
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

  def handle_event("toggle_first_person", _, socket) do
    {:noreply,
     socket
     |> assign(:first_person, !socket.assigns.first_person)}
  end

  def handle_event("vantage:unlock-first-person", _, socket) do
    {:noreply,
     socket
     |> assign(:first_person, false)}
  end

  def handle_event("vantage:set-focus", %{"id" => id}, socket) do
    {:noreply,
     socket
     |> push_patch(to: ~p"/investigations/#{socket.assigns.investigation.id}/projections/#{id}")}
  end

  def handle_event(
        "vantage:set-position",
        %{"id" => id} = attrs,
        socket
      ) do
    keyframe = Keyframes.get_keyframe!(id)
    projection = Projections.get_projection_with_keyframes!(keyframe.projection_id)
    Keyframes.update_keyframe(keyframe, attrs)

    projections =
      socket.assigns.projections
      |> Enum.map(fn p -> if p.id == projection.id, do: projection, else: p end)

    {:noreply, socket |> assign(:projection, projection) |> assign(:projections, projections)}
  end

  def handle_event(
        "vantage:set-rotation",
        %{"id" => id} = attrs,
        socket
      ) do
    keyframe = Keyframes.get_keyframe!(id)
    projection = Projections.get_projection_with_keyframes!(keyframe.projection_id)
    Keyframes.update_keyframe(keyframe, attrs)

    projections =
      socket.assigns.projections
      |> Enum.map(fn p -> if p.id == projection.id, do: projection, else: p end)

    {:noreply, socket |> assign(:projection, projection) |> assign(:projections, projections)}
  end

  def handle_event(
        "vantage:set-fov",
        %{"id" => id} = attrs,
        socket
      ) do
    keyframe = Keyframes.get_keyframe!(id)
    projection = Projections.get_projection_with_keyframes!(keyframe.projection_id)
    Keyframes.update_keyframe(keyframe, attrs)

    projections =
      socket.assigns.projections
      |> Enum.map(fn p -> if p.id == projection.id, do: projection, else: p end)

    {:noreply, socket |> assign(:projection, projection) |> assign(:projections, projections)}
  end

  def handle_event("set-time", time, socket) do
    {:noreply, socket |> assign(:time, time)}
    # {:noreply, socket}
  end

  defp get_position_string(keyframe) do
    "#{keyframe.position_x || 0} #{keyframe.position_y || 0} #{keyframe.position_z || 0}"
  end

  defp get_rotation_string(keyframe) do
    "#{degrees_to_radians(keyframe.rotation_x || 0)} #{degrees_to_radians(keyframe.rotation_y || 0)} #{degrees_to_radians(keyframe.rotation_z || 0)}"
  end

  defp degrees_to_radians(degrees) do
    degrees * :math.pi() / 180
  end
end
