defmodule VantageWeb.InvestigationCreateLive do
  require Logger
  use VantageWeb, :live_view
  alias Vantage.{Investigations, Investigations.Investigation}

  def mount(_params, _session, socket) do
    socket = assign(socket, form: to_form(Investigations.change_investigation(%Investigation{})))

    {
      :ok,
      socket
      |> allow_upload(:avatar, accept: ~w(.jpg .jpeg), max_entries: 1)
      # |> assign(:uploaded_files, [])
    }
  end

  def handle_event("validate", %{"investigation" => params}, socket) do
    changeset =
      %Investigation{}
      |> Investigations.change_investigation(params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :form, to_form(changeset))}
  end

  def handle_event("create", %{"investigation" => params}, socket) do
    model_file =
      consume_uploaded_entries(socket, :avatar, fn %{path: path}, _entry ->
        dest = Path.join([:code.priv_dir(:vantage), "static", "uploads", Path.basename(path)])
        # You will need to create `priv/static/uploads` for `File.cp!/2` to work.
        File.cp!(path, dest)
        {:ok, ~p"/uploads/#{Path.basename(dest)}"}
      end)
      |> List.first()

    Logger.debug(model_file)

    params = Map.put(params, "model", model_file)
    Logger.debug(params)

    case Investigations.create_investigation(socket.assigns.current_user, params) do
      {:ok, _investigation} ->
        # Logger.info("HERE")
        changeset = Investigations.change_investigation(%Investigation{})

        {
          :noreply,
          socket
          |> assign(:form, to_form(changeset))
          # |> update(:uploaded_files, &(&1 ++ model_file))
        }

      {:error, %Ecto.Changeset{} = changeset} ->
        Logger.alert(params)

        {:noreply,
         socket
         |> put_flash(:error, "fucked up")
         |> assign(:form, to_form(changeset))}
    end
  end

  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :avatar, ref)}
  end

  defp error_to_string(:too_large), do: "Too large"
  defp error_to_string(:too_many_files), do: "You have selected too many files"
  defp error_to_string(:not_accepted), do: "You have selected an unacceptable file type"
end
