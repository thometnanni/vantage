defmodule VantageWeb.InvestigationLive.ProjectionInspector do
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
          <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7" />
          </svg>
        </button>

        <button
          phx-click="add-keyframe"
          class="flex items-center justify-center rounded-md hover:bg-gray-200 transition"
          aria-label="Add Keyframe"
        >
          <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4" />
          </svg>
        </button>

        <button
          phx-click="next-keyframe"
          class="flex items-center justify-center rounded-md hover:bg-gray-200 transition"
          aria-label="Next Keyframe"
        >
          <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" />
          </svg>
        </button>

        <button
          phx-click="delete-keyframe"
          class="flex items-center justify-center rounded-md hover:bg-gray-200 transition"
          aria-label="Delete Keyframe"
        >
          <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
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

        <div class="flex gap-2">
          <.input field={@keyframe_form[:position_x]} type="number" label="x" step="any" />
          <.input field={@keyframe_form[:position_z]} type="number" label="y" step="any" />
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
    {:ok,
     socket
     |> assign(assigns)
     |> assign(
       :projection_form,
       to_form(Projections.change_projection(projection))
     )
     |> assign(
       :keyframe_form,
       to_form(Keyframes.change_keyframe(keyframe))
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

    case Keyframes.update_keyframe(socket.assigns.keyframe, keyframe_params) do
      {:ok, keyframe} ->
        notify_parent({:saved_keyframe, keyframe})
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
