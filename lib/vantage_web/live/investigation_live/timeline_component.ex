defmodule VantageWeb.InvestigationLive.TimelineComponent do
  use VantageWeb, :live_component
  require Logger

  alias Vantage.Projections

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex p-4 flex-col gap-2 bg-black border-t border-white overflow-auto">
      <div :for={projection <- @items} class="w-[100%] relative">
        <div class={[
          "absolute bg-white/10 h-1 w-full",
          projection.id == @projection.id && "bg-brand"
        ]}>
        </div>
        <div
          class={[
            "absolute bg-white h-1",
            projection.id == @projection.id && "bg-brand"
          ]}
          style={"left: #{projection.left}; width: #{projection.width}"}
        >
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    min_time = Projections.get_min_time(assigns.investigation.id)
    max_time = Projections.get_max_time(assigns.investigation.id)

    # projections = Projections.list_projections(assigns.investigation.id)

    items =
      assigns.projections
      |> Enum.map(fn projection ->
        %{
          id: projection.id,
          left: "#{get_time(projection.time, min_time, max_time)}%",
          width: "#{get_time(projection.duration, min_time, max_time)}%"
        }
      end)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:items, items)
     |> assign(:max_time, max_time)}
  end

  defp get_time(time, min_time, max_time) do
    ((time || 0.0) - min_time) / (max_time - min_time) * 100
  end

  # @impl true
  # def handle_event("edit-item", %{"id" => id}, socket) do
  #   {:noreply,
  #    socket
  #    |> put_flash(:info, "inspect(unsigned_params)")}

  #   # push_patch(
  #   #           case @type do
  #   #             :models -> ~p"/investigations/#{@id}/models/#{item.id}/edit"
  #   #             :projections -> ~p"/investigations/#{@id}/projections/#{item.id}/edit"
  #   #           end
  #   #         ), replace: true
  # end
end
