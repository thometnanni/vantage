defmodule VantageWeb.KeyframeLive.Show do
  use VantageWeb, :live_view

  alias Vantage.Keyframes

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:keyframe, Keyframes.get_keyframe!(id))}
  end

  defp page_title(:show), do: "Show Keyframe"
  defp page_title(:edit), do: "Edit Keyframe"
end
