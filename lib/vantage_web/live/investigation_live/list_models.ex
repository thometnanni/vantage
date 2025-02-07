defmodule VantageWeb.InvestigationLive.ListModels do
  use VantageWeb, :live_component
  require Logger

  alias Vantage.{Investigations, Investigations.Investigation, Models, Models.Model}

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <div class="flex gap-2 justify-end">
        <.link patch={~p"/investigations/#{@id}/models/new"}>
          <.button>Add Model</.button>
        </.link>
      </div>
      <div :for={model <- @models}>{model.name}</div>
    </div>
    """
  end

  @impl true
  def update(%{investigation: investigation, id: id} = assigns, socket) do
    models = Models.list_models(id)
    Logger.warning("models: #{inspect(models)}")

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:models, models)}
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
