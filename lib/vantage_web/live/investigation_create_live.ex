defmodule VantageWeb.InvestigationCreateLive do
  use VantageWeb, :live_view
  alias Vantage.{Investigations, Investigations.Investigation}

  def mount(_params, _session, socket) do
    socket = assign(socket, form: to_form(Investigations.change_investigation(%Investigation{})))
    {:ok, socket}
  end
end
