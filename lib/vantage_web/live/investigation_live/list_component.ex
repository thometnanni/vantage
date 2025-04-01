defmodule VantageWeb.InvestigationLive.ListComponent do
  use VantageWeb, :live_component
  require Logger

  @impl true
  def render(assigns) do
    ~H"""
    <div
      id="list"
      class="flex flex-1 flex-col gap-2"
      phx-click={
        JS.patch(
          case @type do
            :models -> ~p"/investigations/#{@id}/models"
            :projections -> ~p"/investigations/#{@id}/projections"
          end
        )
      }
    >
      <div class="flex gap-2 justify-end">
        <.link :if={@type == :models} patch={~p"/investigations/#{@id}/models/new"} replace>
          <div
            role="button"
            class="bg-black text-white flex items-center justify-center py-1 px-2 h-8 w-8 rounded-full"
          >
            +
          </div>
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
      <section class="flex flex-col gap-1 relative">
        <div
          :for={item <- @items}
          class={[
            "h-10 flex items-center justify-between item",
            @item_id == item.id && "!bg-brand"
          ]}
          id={"item-#{item.id}"}
          draggable="true"
          phx-hook="DragItem"
          data-item-id={item.id}
          data-item-type={@type}
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
            draggable="false"
          >
            <div class="flex items-center gap-2">
              <div :if={@type == :projections}>
                <%= if item.file =~ ~r/\.(mp4|webm|ogg)$/ do %>
                  <video
                    src={item.file}
                    class="h-10 w-10 object-cover overflow-hidden"
                    muted
                    draggable="false"
                  />
                <% else %>
                  <img
                    src={item.file}
                    class="h-10 w-10 object-cover overflow-hidden"
                    draggable="false"
                  />
                <% end %>
              </div>
              <div class="whitespace-nowrap overflow-hidden flex-1 text-ellipsis">
                {item.name}
              </div>
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
            class="p-2 w-10 flex justify center"
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
  def handle_event("edit-item", %{"id" => _id}, socket) do
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
