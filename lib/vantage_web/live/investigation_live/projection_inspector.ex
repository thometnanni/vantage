defmodule VantageWeb.InvestigationLive.ProjectionInspector do
  alias VantageWeb.GeoUtils
  use VantageWeb, :live_component
  require Logger
  alias Vantage.{Projections, Projections.Projection, Keyframes, Keyframes.Keyframe}

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.simple_form
        for={@projection_form}
        phx-target={@myself}
        phx-change="save"
        phx-submit="save"
        id="projection-form"
      >
        <header class="text-lg">Time</header>
        <.input field={@projection_form[:time]} type="number" label="" step="any" />

        <%!-- <div class="flex gap-2">
          <.input field={@form[:longitude]} type="number" label="Longitude" step="any" />
          <.input field={@form[:latitude]} type="number" label="Latitude" step="any" />
        </div> --%>
      </.simple_form>
      <div class="flex items-center justify-between mt-2 mb-4 pt-2">
        <header class="text-lg leading-none flex items-center h-8">
          Keyframe
        </header>

        <div class="flex space-x-2">
          <button
            phx-click="prev-keyframe"
            class="flex items-center justify-center rounded-md hover:bg-gray-200 transition"
            aria-label="Previous Keyframe"
          >
            <svg
              xmlns="http://www.w3.org/2000/svg"
              class="h-4 w-4"
              fill="none"
              viewBox="0 0 24 24"
              stroke="currentColor"
            >
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M15 19l-7-7 7-7"
              />
            </svg>
          </button>

          <button
            phx-click="add-keyframe"
            class="flex items-center justify-center rounded-md hover:bg-gray-200 transition"
            aria-label="Add Keyframe"
          >
            <svg
              xmlns="http://www.w3.org/2000/svg"
              class="h-4 w-4"
              fill="none"
              viewBox="0 0 24 24"
              stroke="currentColor"
            >
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M12 4v16m8-8H4"
              />
            </svg>
          </button>

          <button
            phx-click="next-keyframe"
            class="flex items-center justify-center rounded-md hover:bg-gray-200 transition"
            aria-label="Next Keyframe"
          >
            <svg
              xmlns="http://www.w3.org/2000/svg"
              class="h-4 w-4"
              fill="none"
              viewBox="0 0 24 24"
              stroke="currentColor"
            >
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" />
            </svg>
          </button>

          <button
            phx-click="delete-keyframe"
            class="flex items-center justify-center rounded-md hover:bg-gray-200 transition"
            aria-label="Delete Keyframe"
          >
            <svg
              xmlns="http://www.w3.org/2000/svg"
              class="h-4 w-4"
              fill="none"
              viewBox="0 0 24 24"
              stroke="currentColor"
            >
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M20 12H4" />
            </svg>
          </button>
        </div>
      </div>

      <.simple_form
        for={@keyframe_form}
        phx-target={@myself}
        phx-change="save-keyframe"
        phx-submit="save-keyframe"
        id="keyframe-form"
      >
        <.input field={@keyframe_form[:time]} type="number" label="Time" step="any" />
        <div class="flex justify-between">
          <span>position</span>

          <button
            type="button"
            class={[
              "flex items-center bg-black/10 rounded-full",
              @has_reference_coordinates && "!bg-brand/20"
            ]}
            phx-click={@has_reference_coordinates && "toggle-use-coordinates"}
            popovertarget="toggle-use-coordinates-info"
            style="anchor-name: --toggle-use-coordinates-anchor;"
          >
            <div
              :if={!@has_reference_coordinates}
              popover="auto"
              id="toggle-use-coordinates-info"
              class="p-2 bg-black text-white rounded-md w-64 m-0 -translate-y-full -translate-x-full text-xs"
              anchor="toggle-use-coordinates"
              style="position: fixed; position-anchor: --toggle-use-coordinates-anchor; left: anchor(right); top: calc(anchor(top) - 0.25rem);"
            >
              specify reference coordindates in the investigation settings to use coordinates
            </div>
            <div class={[
              "flex justify-center items-center rounded-full w-6 h-6",
              !@use_coordinates && @has_reference_coordinates && "!bg-brand",
              !@has_reference_coordinates && "!bg-black/20"
            ]}>
              <.icon name="hero-cube-transparent-micro" />
            </div>
            <div class={[
              "flex justify-center items-center rounded-full w-6 h-6",
              @use_coordinates && "!bg-brand"
            ]}>
              <.icon name="hero-globe-alt-micro" />
            </div>
          </button>
        </div>
        <div class="flex gap-2">
          <%!-- <.tooltip class="px-4 py-2 font-medium text-white bg-black border border-white rounded-md">
            specify reference coordindates in the investigation settings to use coordinates
          </.tooltip> --%>

          <.input
            field={@keyframe_form[:position_x]}
            type="number"
            label={(@use_coordinates && "longitude") || "x"}
            step={(@use_coordinates && 0.00001) || "any"}
          />
          <.input
            field={@keyframe_form[:position_z]}
            type="number"
            label={(@use_coordinates && "latitude") || "y"}
            step={(@use_coordinates && 0.00001) || "any"}
          />
          <.input field={@keyframe_form[:position_y]} type="number" label="height" step="any" />
        </div>

        <div class="flex gap-2">
          <.input field={@keyframe_form[:rotation_x]} type="number" label="pitch" step="any" />
          <.input field={@keyframe_form[:rotation_y]} type="number" label="yaw" step="any" />
          <.input field={@keyframe_form[:rotation_z]} type="number" label="roll" step="any" />
        </div>

        <div class="flex gap-2">
          <.input field={@keyframe_form[:fov]} type="number" label="fov" step="any" class="flex-1" />
          <.input field={@keyframe_form[:far]} type="number" label="far" step="any" class="flex-1" />
          <.input
            field={@keyframe_form[:opacity]}
            type="number"
            label="opacity"
            step="0.01"
            max="1"
            min="0"
            class="flex-1"
          />
        </div>

        <div class="flex gap-2 mb-2"></div>

        <%!-- <div class="flex gap-2">
          <.input field={@form[:longitude]} type="number" label="Longitude" step="any" />
          <.input field={@form[:latitude]} type="number" label="Latitude" step="any" />
        </div> --%>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{projection: projection, keyframe: keyframe} = assigns, socket) do
    # keyframeForm = to_form(Keyframes.change_keyframe(keyframe))

    keyframe =
      if assigns.use_coordinates do
        {lon, lat} =
          GeoUtils.meters_to_coords_alt_2([keyframe.position_x, keyframe.position_z], [
            assigns.reference_longitude,
            assigns.reference_latitude
          ])

        keyframe
        |> Map.put(:position_x, lon)
        |> Map.put(:position_z, lat)
      else
        keyframe
      end

    keyframe_changeset = Keyframes.change_keyframe(keyframe)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(
       :projection_form,
       to_form(Projections.change_projection(projection))
     )
     |> assign(
       :keyframe_form,
       to_form(keyframe_changeset)
     )}
  end

  # @impl true
  # def handle_event("validate", %{"investigation" => investigation_params}, socket) do
  #   changeset =
  #     Investigations.change_investigation(socket.assigns.investigation, investigation_params)

  #   {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  # end

  @impl true
  def handle_event("save", %{"projection" => projection_params}, socket) do
    case Projections.update_projection(socket.assigns.projection, projection_params) do
      {:ok, projection} ->
        notify_parent({:saved, projection})
        changeset = Projections.change_projection(%Projection{})

        {
          :noreply,
          socket
          |> assign(:projection_form, to_form(changeset))
        }

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply,
         socket
         |> put_flash(:error, "Error updating projection")
         |> assign(:projection_form, to_form(changeset))}
    end
  end

  @impl true
  def handle_event("save-keyframe", params, socket) do
    keyframe_params = params["keyframe"]

    position_x =
      case Float.parse(keyframe_params["position_x"]) do
        {value, _} -> value
        :error -> 0.0
      end

    position_z =
      case Float.parse(keyframe_params["position_z"]) do
        {value, _} -> value
        :error -> 0.0
      end

    keyframe_params =
      if socket.assigns.use_coordinates do
        reference_longitude = socket.assigns.reference_longitude
        reference_latitude = socket.assigns.reference_latitude

        {x, y} =
          GeoUtils.coords_to_meters([position_x, position_z], [
            reference_longitude,
            reference_latitude
          ])

        keyframe_params
        |> Map.put("position_x", x)
        |> Map.put("position_z", y)
      else
        keyframe_params
      end

    case Keyframes.update_keyframe(socket.assigns.keyframe, keyframe_params) do
      {:ok, keyframe} ->
        notify_parent({:saved_keyframe, keyframe})

        keyframe =
          keyframe
          |> Map.put(:position_x, position_x)
          |> Map.put(:position_z, position_z)

        changeset = Keyframes.change_keyframe(keyframe)

        {
          :noreply,
          socket
          |> assign(:keyframe_form, to_form(changeset))
        }

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply,
         socket
         |> put_flash(:error, "Error updating keyframe")
         |> assign(:keyframe_form, to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
