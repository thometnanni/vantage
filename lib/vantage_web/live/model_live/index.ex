defmodule VantageWeb.ModelLive.Index do
  use VantageWeb, :live_view
  require Logger
  alias Vantage.Models
  alias Vantage.Models.Model

  @impl true
  def mount(params, _session, socket) do
    Logger.warning("MOUNT    MOUNT - 2")
    {:ok, stream(socket, :models, Models.list_models(params["investigation_id"]))}
  end

  @impl true
  def handle_params(params, _url, socket) do
    Logger.warning("HANDLE PARAMS    HANDLE PARAMS - 2")

    {:noreply,
     socket
     |> apply_action(socket.assigns.live_action, params)
     |> assign(:investigation_id, params["investigation_id"])}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Model")
    |> assign(:model, Models.get_model!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Model")
    |> assign(:model, %Model{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Models")
    |> assign(:model, nil)
  end

  @impl true
  def handle_info({VantageWeb.ModelLive.FormComponent, {:saved, model}}, socket) do
    {:noreply, stream_insert(socket, :models, model)}
  end

  @impl true
  def handle_event("delete", %{"id" => id, "file" => file}, socket) do
    file_path = Path.join([:code.priv_dir(:vantage), "static", "uploads", Path.basename(file)])

    if File.exists?(file_path) do
      File.rm!(file_path)
    end

    model = Models.get_model!(id)
    {:ok, _} = Models.delete_model(model)

    {:noreply, stream_delete(socket, :models, model)}
  end
end
