defmodule VantageWeb.InvestigationLive.ListComponent do
  use VantageWeb, :live_component
  require Logger

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex flex-col gap-2">
      <div class="flex gap-2 justify-end">
        <.link :if={@type == :models} patch={~p"/investigations/#{@id}/models/new"} replace>
          <div role="button" class="bg-black text-white py-1 px-2 rounded-full">Add Model</div>
        </.link>
        <.link :if={@type == :projections} patch={~p"/investigations/#{@id}/projections/new"} replace>
          <div
            role="button"
            class="bg-black text-white flex items-center justify-center py-1 px-2 h-8 w-8 rounded-full"
          >
            +
          </div>
        </.link>
        <%!-- <.link :if={@type == :projections} patch={~p"/investigations/#{@id}/projections/new"} replace>
          <div role="button" class="bg-black text-white py-1 px-2 rounded-full">Add Map</div>
        </.link> --%>
      </div>
      <section class="flex flex-col gap-2">
        <div
          :for={item <- @items}
          class={[
            "h-12 flex items-center justify-between",
            @item_id == item.id && "!bg-brand"
          ]}
          id={"item-#{item.id}"}
        >
          <.link
            patch={
              case @type do
                :models -> ~p"/investigations/#{@id}/models/#{item.id}"
                :projections -> ~p"/investigations/#{@id}/projections/#{item.id}"
              end
            }
            replace
            class="flex-1 overflow-hidden"
          >
            <div class="flex items-center gap-2">
              <div :if={@type == :projections}>
                <%= if item.file =~ ~r/\.(mp4|webm|ogg)$/ do %>
                  <video
                    src={item.file}
                    class="h-12 w-12 object-cover hover:scale-[2] hover:object-contain overflow-hidden"
                    muted
                  />
                <% else %>
                  <img
                    src={item.file}
                    class="h-12 w-12 object-cover hover:scale-[2] hover:object-contain overflow-hidden"
                  />
                <% end %>
              </div>
              <div class="whitespace-nowrap overflow-hidden flex-1 text-ellipsis">{item.name}</div>
            </div>
          </.link>
          <.link
            patch={
              case @type do
                :models -> ~p"/investigations/#{@id}/models/#{item.id}/edit"
                :projections -> ~p"/investigations/#{@id}/projections/#{item.id}/edit"
              end
            }
            replace
            class="p-2 w-8 flex justify center"
          >
            •••
          </.link>
        </div>
      </section>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)}
  end

  @impl true
  def handle_event("edit-item", %{"id" => id}, socket) do
    Logger.warning(id)

    {:noreply,
     socket
     |> put_flash(:info, "inspect(unsigned_params)")}

    # push_patch(
    #           case @type do
    #             :models -> ~p"/investigations/#{@id}/models/#{item.id}/edit"
    #             :projections -> ~p"/investigations/#{@id}/projections/#{item.id}/edit"
    #           end
    #         ), replace: true
  end
end
