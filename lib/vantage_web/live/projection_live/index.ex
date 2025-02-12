defmodule VantageWeb.ProjectionLive.Index do
  require Logger
  use VantageWeb, :live_view

  alias Vantage.Projections
  alias Vantage.Projections.Projection

  @impl true
  def mount(params, _session, socket) do
    {:ok, stream(socket, :projections, Projections.list_projections(params["investigation_id"]))}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply,
     socket
     |> apply_action(socket.assigns.live_action, params)
     |> assign(:investigation_id, params["investigation_id"])}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Projection")
    |> assign(:projection, Projections.get_projection!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Projection")
    |> assign(:projection, %Projection{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Projections")
    |> assign(:projection, nil)
  end

  @impl true
  def handle_info({VantageWeb.ProjectionLive.FormComponent, {:saved, projection}}, socket) do
    {:noreply, stream_insert(socket, :projections, projection)}
  end

  @impl true
  def handle_event(
        "delete",
        %{"id" => id, "file" => file, "investigation_id" => investigation_id},
        socket
      ) do
    if file do
      file_path = Path.join([:code.priv_dir(:vantage), "static", "uploads", Path.basename(file)])

      if File.exists?(file_path) do
        File.rm!(file_path)
      end
    end

    projection = Projections.get_projection!(id)
    {:ok, _} = Projections.delete_projection(projection)

    # Logger.warning(~p"/investigations/#{investigation_id}")

    {
      :noreply,
      socket
      |> stream_delete(:projections, projection)
      #  |> push_patch(to: ~p"/investigations/#{investigation_id}/projections", replace: true)
    }
  end
end
