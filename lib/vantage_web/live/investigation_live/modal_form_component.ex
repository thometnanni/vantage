defmodule VantageWeb.InvestigationLive.ModalFormComponent do
  require Logger
  use VantageWeb, :live_component

  alias Vantage.{Projections, Models, Keyframes}

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {@title}
      </.header>

      <.simple_form
        for={@form}
        id="modal-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <section
          class="h-32 bg-gray-200"
          phx-drop-target={@uploads.media.ref}
          phx-hook="OpenFileDialogue"
          id="drop-target"
        >
          <.live_file_input upload={@uploads.media} class="hidden" />
          <%!-- render each media entry --%>
          <%= if @uploads.media.entries != [] do %>
            <article :for={entry <- @uploads.media.entries} class="upload-entry">
              <.live_img_preview class="h-32" entry={entry} />

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
          <% else %>
            <article class="upload-entry">
              <%= if @item.file do %>
                <img class="h-32" src={@item.file} />
              <% else %>
                <div>Drop or select file</div>
              <% end %>
            </article>
          <% end %>

          <%!-- Phoenix.Component.upload_errors/1 returns a list of error atoms --%>
          <p :for={err <- upload_errors(@uploads.media)} class="alert alert-danger">
            {error_to_string(err)}
          </p>
        </section>
        <.input
          field={@form[:name]}
          type="text"
          label="Name"
          placeholder={get_filename(@uploads.media)}
        />
        <div :if={@type == :projection}>
          <label>Projection Type</label>
          <.radio_group field={@form[:projection_type]}>
            <:radio value="perspective">perspective</:radio>
            <:radio value="orthographic">orthographic</:radio>
            <:radio value="map">map</:radio>
          </.radio_group>
        </div>
        <%!-- <.input field={@form[:time]} type="number" label="Time" step="any" /> --%>
        <:actions>
          <.button phx-disable-with="Saving...">{@save_string}</.button>
          <.button
            :if={@action == :edit}
            type="button"
            phx-click={
              JS.push("delete",
                value: %{
                  id: @item.id,
                  investigation_id: @investigation_id
                },
                target: @myself
              )

              # |> hide("##{@projection.id}")
              # |> hide("#item-#{@projection.id}")
            }
            data-confirm="Are you sure?"
          >
            Delete
          </.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{item: item, id: id, type: type} = assigns, socket) do
    title =
      "#{(id == :new && "New") || "Edit"} #{(type == :projection && "projection") || "model"}"

    save_string =
      "#{(id == :new && "Create") || "Save"} #{(type == :projection && "projection") || "model"}"

    {
      :ok,
      socket
      |> assign(assigns)
      |> assign_new(:form, fn ->
        case type do
          :projection ->
            to_form(Projections.change_projection(item))

          :model ->
            to_form(Models.change_model(item))
        end
      end)
      |> assign(:title, title)
      |> assign(:save_string, save_string)
      |> assign(:uploaded_files, [])
      |> allow_upload(:media,
        accept:
          case type do
            :projection ->
              ~w(.png .jpg .jpeg .gif .mp4 .webm)

            :model ->
              ~w(.gltf .glb)
          end,
        max_entries: 1,
        max_file_size: 100_000_000
      )
    }
  end

  @impl true
  def handle_event("validate", params, socket) do
    changeset =
      case socket.assigns.type do
        :projection -> Projections.change_projection(socket.assigns.item, params["projection"])
        :model -> Models.change_model(socket.assigns.item, params["model"])
      end

    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", params, socket) do
    current_media_file = socket.assigns.item.file

    media_file =
      consume_uploaded_entries(socket, :media, fn %{path: path}, entry ->
        dest =
          Path.join([
            :code.priv_dir(:vantage),
            "static",
            "uploads",
            "#{Path.basename(path)}-#{entry.client_name}"
          ])

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

    item_params =
      case socket.assigns.type do
        :projection -> params["projection"]
        :model -> params["model"]
      end

    item_params =
      if media_file do
        Map.put(item_params, "file", media_file)
      else
        item_params
      end

    item_params =
      if item_params["name"] == nil or item_params["name"] == "" do
        Map.put(item_params, "name", get_filename(socket.assigns.uploads[:media]))
      else
        item_params
      end

    save_item(socket, socket.assigns.action, socket.assigns.type, item_params)
  end

  @impl true
  def handle_event(
        "delete",
        %{"id" => id},
        socket
      ) do
    item =
      case socket.assigns.type do
        :projection -> Projections.get_projection!(id)
        :model -> Models.get_model!(id)
      end

    if item.file do
      file_path =
        Path.join([:code.priv_dir(:vantage), "static", "uploads", Path.basename(item.file)])

      if File.exists?(file_path) do
        File.rm!(file_path)
      end
    end

    deletion =
      case socket.assigns.type do
        :projection -> Projections.delete_projection(item)
        :model -> Models.delete_model(item)
      end

    case deletion do
      {:ok, item} ->
        notify_parent(
          {case socket.assigns.type do
             :projection -> :deleted_projection
             :model -> :deleted_model
           end, item}
        )

        {:noreply,
         socket
         |> push_patch(to: socket.assigns.patch, replace: true)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  @impl true
  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :media, ref)}
  end

  defp save_item(socket, :edit, :projection, projection_params) do
    case Projections.update_projection(socket.assigns.item, projection_params) do
      {:ok, projection} ->
        notify_parent({:saved_projection, projection})

        {:noreply,
         socket
         |> put_flash(:info, "Projection updated successfully")
         |> push_patch(to: "#{socket.assigns.patch}/#{projection.id}", replace: true)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_item(socket, :edit, :model, model_params) do
    case Models.update_model(socket.assigns.item, model_params) do
      {:ok, model} ->
        notify_parent({:saved_model, model})

        {:noreply,
         socket
         |> put_flash(:info, "Model updated successfully")
         |> push_patch(to: "#{socket.assigns.patch}/#{model.id}", replace: true)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_item(socket, :new, :projection, projection_params) do
    investigation_id = socket.assigns.investigation_id
    projection_params = Map.put(projection_params, "investigation_id", investigation_id)

    {:noreply, socket}

    case Projections.create_projection(projection_params) do
      {:ok, projection} ->
        keyframe = Map.from_struct(%Keyframes.Keyframe{projection_id: projection.id})

        case Keyframes.create_keyframe(keyframe) do
          {:ok, _} ->
            notify_parent({:saved_projection, projection})

            {:noreply,
             socket
             |> put_flash(:info, "Projection created successfully")
             |> push_patch(to: "#{socket.assigns.patch}/#{projection.id}", replace: true)}

          {:error, %Ecto.Changeset{} = _} ->
            {:noreply, put_flash(socket, :error, "Error creating projection")}
        end

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_item(socket, :new, :model, model_params) do
    investigation_id = socket.assigns.investigation_id
    model_params = Map.put(model_params, "investigation_id", investigation_id)

    case Models.create_model(model_params) do
      {:ok, model} ->
        notify_parent({:saved_model, model})

        {:noreply,
         socket
         |> put_flash(:info, "Model created successfully")
         |> push_patch(to: "#{socket.assigns.patch}/#{model.id}", replace: true)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp get_filename(upload) do
    if upload.entries != [] do
      filename = Enum.at(upload.entries, 0).client_name
      Path.basename(filename, Path.extname(filename))
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})

  defp error_to_string(:too_large), do: "Too large"
  defp error_to_string(:not_accepted), do: "You have selected an unacceptable file type"
  defp error_to_string(:too_many_files), do: "You have selected too many files"
end
