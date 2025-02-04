defmodule VantageWeb.ModelLive.FormComponent do
  use VantageWeb, :live_component

  alias Vantage.Models

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {@title}
        <:subtitle>Use this form to manage model records in your database.</:subtitle>
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
        id="model-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="Name" />
        <%!-- <.input field={@form[:file]} type="text" label="File" /> --%>
        <.live_file_input upload={@uploads.media} />
        <:actions>
          <.button phx-disable-with="Saving...">Save Model</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{model: model} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Models.change_model(model))
     end)
     |> assign(:uploaded_files, [])
     |> allow_upload(:media, accept: ~w(.glb .gltf), max_entries: 1)}
  end

  @impl true
  def handle_event("validate", %{"model" => model_params}, socket) do
    changeset = Models.change_model(socket.assigns.model, model_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"model" => model_params}, socket) do
    current_media_file = socket.assigns.model.file

    media_file =
      consume_uploaded_entries(socket, :media, fn %{path: path}, _entry ->
        dest = Path.join([:code.priv_dir(:vantage), "static", "uploads", Path.basename(path)])
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

    model_params =
      if media_file do
        Map.put(model_params, "file", media_file)
      else
        model_params
      end

    save_model(socket, socket.assigns.action, model_params)
  end

  @impl true
  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :media, ref)}
  end

  defp save_model(socket, :edit, model_params) do
    case Models.update_model(socket.assigns.model, model_params) do
      {:ok, model} ->
        notify_parent({:saved, model})

        {:noreply,
         socket
         |> put_flash(:info, "Model updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_model(socket, :new, model_params) do
    investigation_id = socket.assigns.investigation_id
    model_params = Map.put(model_params, "investigation_id", investigation_id)

    case Models.create_model(model_params) do
      {:ok, model} ->
        notify_parent({:saved, model})

        {:noreply,
         socket
         |> put_flash(:info, "Model created successfully")
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
