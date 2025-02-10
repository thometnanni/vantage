defmodule VantageWeb.ProjectionLive.FormComponent do
  use VantageWeb, :live_component

  alias Vantage.Projections

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {@title}
        <:subtitle>Use this form to manage projection records in your database.</:subtitle>
      </.header>

      <section phx-drop-target={@uploads.media.ref}>
        <%!-- render each media entry --%>
        <article :for={entry <- @uploads.media.entries} class="upload-entry">
          <figure>
            <.live_img_preview entry={entry} />
            <figcaption>{entry.client_name}</figcaption>
          </figure>

          <%!-- entry.progress will update automatically for in-flight entries --%>
          <progress value={entry.progress} max="100">{entry.progress}%</progress>

          <%!-- a regular click event whose handler will invoke Phoenix.LiveView.cancel_upload/3 --%>
          <button
            type="button"
            phx-click="cancel-upload"
            phx-value-ref={entry.ref}
            aria-label="cancel"
          >
            &times;
          </button>

          <%!-- Phoenix.Component.upload_errors/2 returns a list of error atoms --%>
          <p :for={err <- upload_errors(@uploads.media, entry)} class="alert alert-danger">
            {error_to_string(err)}
          </p>
        </article>

        <%!-- Phoenix.Component.upload_errors/1 returns a list of error atoms --%>
        <p :for={err <- upload_errors(@uploads.media)} class="alert alert-danger">
          {error_to_string(err)}
        </p>
      </section>

      <.simple_form
        for={@form}
        id="projection-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="Name" />
        <%!-- <.input field={@form[:file]} type="text" label="File" /> --%>
        <.live_file_input upload={@uploads.media} />
        <div>
          <label>Projection Type</label>
          <.radio_group field={@form[:projection_type]}>
            <:radio value="perspective">perspective</:radio>
            <:radio value="orthographic">orthographic</:radio>
            <:radio value="map">map</:radio>
          </.radio_group>
        </div>
        <.input field={@form[:time]} type="number" label="Time" step="any" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Projection</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{projection: projection} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Projections.change_projection(projection))
     end)
     |> assign(:uploaded_files, [])
     |> allow_upload(:media, accept: ~w(.png .jpg .jpeg .gif .mp4 .webm), max_entries: 1)}
  end

  @impl true
  def handle_event("validate", %{"projection" => projection_params}, socket) do
    changeset = Projections.change_projection(socket.assigns.projection, projection_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"projection" => projection_params}, socket) do
    current_media_file = socket.assigns.projection.file

    media_file =
      consume_uploaded_entries(socket, :media, fn %{path: path}, entry ->
        dest =
          Path.join([
            :code.priv_dir(:vantage),
            "static",
            "uploads",
            "#{Path.basename(path)}-#{entry.client_name}"
          ])

        # You will need to create `priv/static/uploads` for `File.cp!/2` to work.
        File.cp!(path, dest)
        {:ok, ~p"/uploads/#{Path.basename(dest)}"}
      end)
      |> List.first()

    if current_media_file && media_file do
      old_file_path = Path.join([:code.priv_dir(:vantage), "static", current_media_file])

      if File.exists?(old_file_path) do
        File.rm!(old_file_path)
      end
    end

    projection_params =
      if media_file do
        Map.put(projection_params, "file", media_file)
      else
        projection_params
      end

    save_projection(socket, socket.assigns.action, projection_params)
  end

  @impl true
  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :media, ref)}
  end

  defp save_projection(socket, :edit, projection_params) do
    case Projections.update_projection(socket.assigns.projection, projection_params) do
      {:ok, projection} ->
        notify_parent({:saved, projection})

        {:noreply,
         socket
         |> put_flash(:info, "Projection updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_projection(socket, :new, projection_params) do
    investigation_id = socket.assigns.investigation_id
    projection_params = Map.put(projection_params, "investigation_id", investigation_id)

    case Projections.create_projection(projection_params) do
      {:ok, projection} ->
        notify_parent({:saved, projection})

        {:noreply,
         socket
         |> put_flash(:info, "Projection created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})

  defp error_to_string(:too_large), do: "Too large"
  defp error_to_string(:not_accepted), do: "You have selected an unacceptable file type"
  defp error_to_string(:too_many_files), do: "You have selected too many files"
end
