defmodule VantageWeb.PageController do
  use VantageWeb, :controller

  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    if conn.assigns[:current_user] do
      redirect(conn, to: "/investigations")
    else
      render(conn, :home, layout: {VantageWeb.Layouts, :full})
    end
  end
end
