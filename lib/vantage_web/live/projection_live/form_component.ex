defmodule VantageWeb.ProjectionLive.FormComponent do
  use VantageWeb, :live_component

  alias Vantage.Projections

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {@title}
        <:subtitle>Use this form to manage projection records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="projection-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:file]} type="text" label="File" />
        <.input field={@form[:orthographic]} type="checkbox" label="Orthographic" />
        <.input field={@form[:time]} type="number" label="Time" step="any" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Projection</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{projection: projection} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Projections.change_projection(projection))
     end)}
  end

  @impl true
  def handle_event("validate", %{"projection" => projection_params}, socket) do
    changeset = Projections.change_projection(socket.assigns.projection, projection_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"projection" => projection_params}, socket) do
    save_projection(socket, socket.assigns.action, projection_params)
  end

  defp save_projection(socket, :edit, projection_params) do
    case Projections.update_projection(socket.assigns.projection, projection_params) do
      {:ok, projection} ->
        notify_parent({:saved, projection})

        {:noreply,
         socket
         |> put_flash(:info, "Projection updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_projection(socket, :new, projection_params) do
    case Projections.create_projection(projection_params) do
      {:ok, projection} ->
        notify_parent({:saved, projection})

        {:noreply,
         socket
         |> put_flash(:info, "Projection created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
