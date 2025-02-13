defmodule VantageWeb.InvestigationLive.FormInvestigation do
  use VantageWeb, :live_component
  require Logger

  alias Vantage.{Investigations, Investigations.Investigation}

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.simple_form
        for={@form}
        phx-target={@myself}
        phx-change="save"
        phx-submit="save"
        id="investigation-form"
      >
        <.input field={@form[:name]} label="Title" placeholder={@name_placeholder} />
        <.input field={@form[:description]} label="Description" />
        <.input field={@form[:time]} label="Time" type="datetime-local" />

        <div class="flex gap-2">
          <.input field={@form[:longitude]} type="number" label="Longitude" step="any" />
          <.input field={@form[:latitude]} type="number" label="Latitude" step="any" />
        </div>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{investigation: investigation} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign(:name_placeholder, %Investigation{}.name)
     |> assign_new(:form, fn ->
       to_form(Investigations.change_investigation(investigation))
     end)}
  end

  # @impl true
  # def handle_event("validate", %{"investigation" => investigation_params}, socket) do
  #   changeset =
  #     Investigations.change_investigation(socket.assigns.investigation, investigation_params)

  #   {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  # end

  @impl true
  def handle_event("save", %{"investigation" => investigation_params}, socket) do
    case Investigations.update_investigation(socket.assigns.investigation, investigation_params) do
      {:ok, investigation} ->
        notify_parent({:saved, investigation})
        changeset = Investigations.change_investigation(%Investigation{})

        {
          :noreply,
          socket
          |> assign(:form, to_form(changeset))
        }

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply,
         socket
         |> put_flash(:error, "Error updating investigation")
         |> assign(:form, to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
