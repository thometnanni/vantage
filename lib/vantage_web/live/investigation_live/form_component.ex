defmodule VantageWeb.InvestigationLive.FormComponent do
  use VantageWeb, :live_component

  alias Vantage.Investigations

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {@title}
        <:subtitle>Use this form to manage investigation records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="investigation-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:description]} type="text" label="Description" />
        <.input field={@form[:longitude]} type="number" label="Longitude" step="any" />
        <.input field={@form[:latitude]} type="number" label="Latitude" step="any" />
        <.input field={@form[:time]} type="text" label="Time" type="datetime-local" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Investigation</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{investigation: investigation} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Investigations.change_investigation(investigation))
     end)}
  end

  @impl true
  def handle_event("validate", %{"investigation" => investigation_params}, socket) do
    changeset =
      Investigations.change_investigation(socket.assigns.investigation, investigation_params)

    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"investigation" => investigation_params}, socket) do
    save_investigation(socket, socket.assigns.action, investigation_params)
  end

  defp save_investigation(socket, :edit, investigation_params) do
    case Investigations.update_investigation(socket.assigns.investigation, investigation_params) do
      {:ok, investigation} ->
        notify_parent({:saved, investigation})

        {:noreply,
         socket
         |> put_flash(:info, "Investigation updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_investigation(socket, :new, investigation_params) do
    case Investigations.create_investigation(socket.assigns.current_user, investigation_params) do
      {:ok, investigation} ->
        notify_parent({:saved, investigation})

        {:noreply,
         socket
         |> put_flash(:info, "Investigation created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
