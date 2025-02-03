defmodule VantageWeb.KeyframeLive.Index do
  use VantageWeb, :live_view

  alias Vantage.Keyframes
  alias Vantage.Keyframes.Keyframe

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :keyframes, Keyframes.list_keyframes())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Keyframe")
    |> assign(:keyframe, Keyframes.get_keyframe!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Keyframe")
    |> assign(:keyframe, %Keyframe{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Keyframes")
    |> assign(:keyframe, nil)
  end

  @impl true
  def handle_info({VantageWeb.KeyframeLive.FormComponent, {:saved, keyframe}}, socket) do
    {:noreply, stream_insert(socket, :keyframes, keyframe)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    keyframe = Keyframes.get_keyframe!(id)
    {:ok, _} = Keyframes.delete_keyframe(keyframe)

    {:noreply, stream_delete(socket, :keyframes, keyframe)}
  end
end
