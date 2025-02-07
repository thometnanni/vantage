defmodule VantageWeb.InvestigationLive.ListProjections do
  use VantageWeb, :live_component
  require Logger

  alias Vantage.{
    Investigations,
    Investigations.Investigation,
    Projections,
    Projections.Projection
  }

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <div class="flex gap-2 justify-end">
        <.link patch={~p"/investigations/#{@id}/projections/new"}>
          <.button>Add Projection</.button>
        </.link>
      </div>
      <div :for={projection <- @projections}>{projection.name}</div>
    </div>
    """
  end

  @impl true
  def update(%{investigation: investigation, id: id} = assigns, socket) do
    projections = Projections.list_projections(id)
    Logger.warning("projections: #{inspect(projections)}")

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:projections, projections)}
  end

  # @impl true
  # def handle_event("validate", %{"investigation" => investigation_params}, socket) do
  #   changeset =
  #     Investigations.change_investigation(socket.assigns.investigation, investigation_params)

  #   {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  # end

  @impl true
  def handle_event("save", %{"investigation" => investigation_params}, socket) do
    Logger.warning("investigation in form")

    case Investigations.update_investigation(socket.assigns.investigation, investigation_params) do
      {:ok, investigation} ->
        notify_parent({:saved, investigation})
        changeset = Investigations.change_investigation(%Investigation{})

        {
          :noreply,
          socket
          |> assign(:investigation_form, to_form(changeset))
        }

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply,
         socket
         |> put_flash(:error, "Error updating investigation")
         |> assign(:investigation_form, to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
