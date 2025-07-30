defmodule VantageWeb.InvestigationLive.FormInvestigationCollaborators do
  use VantageWeb, :live_component
  require Logger

  alias Vantage.{
    Investigations,
    Investigations.Investigation,
    Investigations.InvestigationCollaborator
  }

  @impl true
  def render(assigns) do
    ~H"""
    <div class="mt-4">
      <h3 class="block text-sm font-semibold leading-6 text-zinc-800">Collaborators</h3>
      <div>
        <div :for={user_role <- @user_roles} class="flex gap-2">
          <div class="flex-1">{user_role.email}</div>
          <form phx-change="update_role" phx-target={@myself}>
            <input type="hidden" name="user_id" value={user_role.user_id} />
            <select
              name="role"
              class="block flex-1 rounded-md text-zinc-900 focus:ring-0 sm:text-xs sm:leading-1 border-zinc-300 focus:border-zinc-400"
              id={"role-select-#{user_role.user_id}"}
            >
              <option value="owner" selected={user_role.role == :owner}>Owner</option>
              <option value="writer" selected={user_role.role == :writer}>Writer</option>
              <option value="reader" selected={user_role.role == :reader}>Reader</option>
              <option value="remove">Remove</option>
            </select>
          </form>
        </div>
      </div>
      <div>
        <form phx-submit="add_user" class="flex gap-2" phx-target={@myself}>
          <input
            type="text"
            name="email"
            class="block w-full rounded-md text-zinc-900 focus:ring-0 sm:text-xs sm:leading-1 border-zinc-300 focus:border-zinc-400"
            placeholder="email"
          />
          <button
            type="submit"
            class="rounded-lg bg-zinc-900 hover:bg-zinc-700 py-2 px-3 text-sm font-semibold leading-6 text-white active:text-white/80"
          >
            Add
          </button>
        </form>
      </div>
    </div>
    """
  end

  @impl true
  def update(%{investigation: investigation, current_user: current_user} = assigns, socket) do
    user_roles =
      Investigations.get_user_roles_for_investigation(investigation.id)
      |> Enum.reject(fn ur -> ur.user_id == current_user.id end)

    Logger.info(inspect(user_roles))

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:user_roles, user_roles)
     |> assign(:name_placeholder, %Investigation{}.name)
     |> assign_new(:form, fn ->
       to_form(Investigations.change_investigation(investigation))
     end)}
  end

  @impl true
  def handle_event("update_role", %{"role" => role, "user_id" => user_id}, socket) do
    case role do
      "remove" ->
        Investigations.remove_user_from_investigation(socket.assigns.investigation.id, user_id)
        {:noreply, socket}

      _ ->
        Investigations.update_user_role_in_investigation(
          socket.assigns.investigation.id,
          user_id,
          String.to_existing_atom(role)
        )

        user_roles =
          load_user_roles(socket.assigns.investigation.id, socket.assigns.current_user.id)

        {:noreply, assign(socket, :user_roles, user_roles)}
    end
  end

  @impl true
  def handle_event("add_user", %{"email" => email}, socket) do
    email = String.trim(email)

    if email != "" do
      case Investigations.add_user_to_investigation(
             socket.assigns.investigation.id,
             email
           ) do
        {:ok, _} ->
          user_roles =
            load_user_roles(socket.assigns.investigation.id, socket.assigns.current_user.id)

          {:noreply, assign(socket, :user_roles, user_roles)}

        {:error, :user_not_found} ->
          send(self(), {:put_flash, :error, "User not found."})
          {:noreply, socket}

        {:error, _} ->
          send(self(), {:put_flash, :error, "Failed to add user."})
          {:noreply, socket}
      end
    else
      send(self(), {:put_flash, :error, "Email cannot be empty."})
      {:noreply, socket}
    end
  end

  defp load_user_roles(investigation_id, current_user_id) do
    Investigations.get_user_roles_for_investigation(investigation_id)
    |> Enum.reject(fn ur -> ur.user_id == current_user_id end)
  end
end
