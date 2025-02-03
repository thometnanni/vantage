defmodule VantageWeb.InvestigationCollaboratorLive.FormComponent do
  use VantageWeb, :live_component

  alias Vantage.Investigations

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {@title}
        <:subtitle>Use this form to manage investigation_collaborator records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="investigation_collaborator-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:role]} type="text" label="Role" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Investigation collaborator</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{investigation_collaborator: investigation_collaborator} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Investigations.change_investigation_collaborator(investigation_collaborator))
     end)}
  end

  @impl true
  def handle_event("validate", %{"investigation_collaborator" => investigation_collaborator_params}, socket) do
    changeset = Investigations.change_investigation_collaborator(socket.assigns.investigation_collaborator, investigation_collaborator_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"investigation_collaborator" => investigation_collaborator_params}, socket) do
    save_investigation_collaborator(socket, socket.assigns.action, investigation_collaborator_params)
  end

  defp save_investigation_collaborator(socket, :edit, investigation_collaborator_params) do
    case Investigations.update_investigation_collaborator(socket.assigns.investigation_collaborator, investigation_collaborator_params) do
      {:ok, investigation_collaborator} ->
        notify_parent({:saved, investigation_collaborator})

        {:noreply,
         socket
         |> put_flash(:info, "Investigation collaborator updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_investigation_collaborator(socket, :new, investigation_collaborator_params) do
    case Investigations.create_investigation_collaborator(investigation_collaborator_params) do
      {:ok, investigation_collaborator} ->
        notify_parent({:saved, investigation_collaborator})

        {:noreply,
         socket
         |> put_flash(:info, "Investigation collaborator created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
