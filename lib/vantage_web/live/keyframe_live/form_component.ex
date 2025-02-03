defmodule VantageWeb.KeyframeLive.FormComponent do
  use VantageWeb, :live_component

  alias Vantage.Keyframes

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {@title}
        <:subtitle>Use this form to manage keyframe records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="keyframe-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:time]} type="number" label="Time" step="any" />
        <.input
          field={@form[:position]}
          type="select"
          multiple
          label="Position"
          options={[]}
        />
        <.input
          field={@form[:rotation]}
          type="select"
          multiple
          label="Rotation"
          options={[]}
        />
        <.input field={@form[:far]} type="number" label="Far" step="any" />
        <.input field={@form[:fov]} type="number" label="Fov" step="any" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Keyframe</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{keyframe: keyframe} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Keyframes.change_keyframe(keyframe))
     end)}
  end

  @impl true
  def handle_event("validate", %{"keyframe" => keyframe_params}, socket) do
    changeset = Keyframes.change_keyframe(socket.assigns.keyframe, keyframe_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"keyframe" => keyframe_params}, socket) do
    save_keyframe(socket, socket.assigns.action, keyframe_params)
  end

  defp save_keyframe(socket, :edit, keyframe_params) do
    case Keyframes.update_keyframe(socket.assigns.keyframe, keyframe_params) do
      {:ok, keyframe} ->
        notify_parent({:saved, keyframe})

        {:noreply,
         socket
         |> put_flash(:info, "Keyframe updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_keyframe(socket, :new, keyframe_params) do
    case Keyframes.create_keyframe(keyframe_params) do
      {:ok, keyframe} ->
        notify_parent({:saved, keyframe})

        {:noreply,
         socket
         |> put_flash(:info, "Keyframe created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
