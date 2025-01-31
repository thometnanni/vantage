defmodule VantageWeb.InvestigationLive.Index do
  use VantageWeb, :live_view
  alias Vantage.{Investigations, Investigations.Investigation}

  require Logger
  @impl true
  def mount(_params, _session, socket) do
    investigations = Investigations.list_investigations()

    formatted_investigations =
      Enum.map(investigations, fn investigation ->
        Map.put(
          investigation,
          :formatted_inserted_at,
          Timex.format!(investigation.inserted_at, "{Mfull} {D}, {YYYY} {h24}:{m}")
        )
      end)

    {:ok, stream(socket, :investigations, formatted_investigations)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Investigation")
    |> assign(:investigation, Investigations.get_investigation!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Investigation")
    |> assign(:investigation, %Investigation{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Investigations")
    |> assign(:investigation, nil)
    |> assign(form: to_form(Investigations.change_investigation(%Investigation{})))
  end

  @impl true
  def handle_info({HelloWeb.InvestigationLive.FormComponent, {:saved, investigation}}, socket) do
    {:noreply, stream_insert(socket, :investigations, investigation)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    investigation = Investigations.get_investigation!(id)
    {:ok, _} = Investigations.delete_investigation(investigation)

    {:noreply, stream_delete(socket, :investigations, investigation)}
  end

  @impl true
  def handle_event("new_investigation", _params, socket) do
    case Investigations.create_investigation(socket.assigns.current_user, %{}) do
      {:ok, investigation} ->
        Logger.debug("______")

        formatted_investigation =
          Map.put(
            investigation,
            :formatted_inserted_at,
            Timex.format!(investigation.inserted_at, "{Mfull} {D}, {YYYY} {h24}:{m}")
          )

        {
          :noreply,
          socket
          |> stream_insert(:investigations, formatted_investigation)
          |> put_flash(:info, "New investigation created successfully")
          |> push_navigate(to: ~p"/investigations/#{investigation.id}")

        }

      {:error, _err} ->
        {:noreply,
         socket
         |> put_flash(:error, "Failed to create investigation")}
    end
  end

  defp format_investigations(investigations) do
    Enum.map(investigations, fn investigation ->
      Map.put(
        investigation,
        :formatted_inserted_at,
        Timex.format!(investigation.inserted_at, "{Mfull} {D}, {YYYY} {h24}:{m}")
      )
    end)
  end

  # @impl true
  # def handle_event("new_investigation", _params, socket) do
  #   case Investigations.create_investigation(socket.assigns.current_user, %Investigation{}) do
  #     {:ok, _investigation} ->
  #       # Logger.info("HERE")
  #       # changeset = Investigations.change_investigation(%Investigation{})

  #       {
  #         :noreply,
  #         socket
  #         # |> assign(:form, to_form(changeset))
  #         # |> update(:uploaded_files, &(&1 ++ model_file))
  #       }

  #     {:error, %Ecto.Changeset{} = changeset} ->
  #       # Logger.alert(params)

  #       {:noreply,
  #        socket
  #        |> put_flash(:error, "fucked up")
  #        |> assign(:form, to_form(changeset))}
  #   end
  # end
end
