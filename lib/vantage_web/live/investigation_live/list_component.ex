defmodule VantageWeb.InvestigationLive.ListComponent do
  use VantageWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <div class="flex gap-2 justify-end">
        <.link :if={@type == :models} patch={~p"/investigations/#{@id}/models/new"} replace>
          <div role="button" class="bg-black text-white py-1 px-2 rounded-full">Add Model</div>
        </.link>
        <.link :if={@type == :projections} patch={~p"/investigations/#{@id}/projections/new"} replace>
          <div role="button" class="bg-black text-white py-1 px-2 rounded-full">Add Media</div>
        </.link>
        <.link :if={@type == :projections} patch={~p"/investigations/#{@id}/projections/new"} replace>
          <div role="button" class="bg-black text-white py-1 px-2 rounded-full">Add Map</div>
        </.link>
      </div>
      <.link
        :for={item <- @items}
        patch={
          case @type do
            :models -> ~p"/investigations/#{@id}/models/#{item.id}"
            :projections -> ~p"/investigations/#{@id}/projections/#{item.id}"
          end
        }
        replace
      >
        <div>{item.name}</div>
      </.link>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)}
  end
end
