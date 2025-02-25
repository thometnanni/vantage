defmodule VantageWeb.InvestigationLive.TimelineComponent do
  use VantageWeb, :live_component
  require Logger

  alias Vantage.Projections

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex p-4 flex-col gap-2 bg-black border-t border-white overflow-auto">
      <div class="time flex justify-between text-white">
        <div>{@min_time}</div>
        <button>play/pause</button>
        <div>{@max_time}</div>
      </div>
      <div
        class="relative flex flex-col gap-1"
        id="timeline-scrubber"
        phx-hook="TimelineScrubber"
        data-max-time={@max_time}
        data-min-time={@min_time}
      >
        <div
          id="timeline-cursor"
          class="absolute h-full w-[1px] bg-brand"
          style={"left: #{@cursor_position}%"}
        >
        </div>
        <div :for={projection <- @items} class="w-[100%] relative h-1">
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
            style={"left: #{projection.left}; width: max(#{projection.width}, 1px)"}
          >
          </div>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    min_time =
      Projections.get_min_time(assigns.investigation.id)
      |> Float.floor()
      |> Kernel.min(0.0)

    max_time =
      Projections.get_max_time(assigns.investigation.id)
      |> Float.ceil()
      |> Kernel.max(10.0)

    # projections = Projections.list_projections(assigns.investigation.id)

    items =
      assigns.projections
      |> Enum.map(fn projection ->
        %{
          id: projection.id,
          left: "#{get_time(projection.time, min_time, max_time)}%",
          width: "#{get_duration(projection.duration, min_time, max_time)}%"
        }
      end)

    cursor_position = get_time(assigns.time, min_time, max_time)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:items, items)
     |> assign(:cursor_position, cursor_position)
     |> assign(:max_time, max_time)
     |> assign(:min_time, min_time)}
  end

  defp get_time(time, min_time, max_time) do
    ((time || 0.0) - min_time) / (max_time - min_time) * 100
  end

  defp get_duration(time, min_time, max_time) do
    (time || 0.0) / (max_time - min_time) * 100
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
