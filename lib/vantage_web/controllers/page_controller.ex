defmodule VantageWeb.PageController do
  use VantageWeb, :controller

  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    # render(conn, :home)
    redirect(conn, to: "/investigations")
  end
end
