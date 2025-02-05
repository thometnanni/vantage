defmodule VantageWeb.Layouts.Root do
  alias Phoenix.LiveView.JS

  def toggle_user_menu do
    JS.toggle(
      to: "#user-menu"
      # in: {"transition ease-out duration-100", "opacity-0", "opacity-100"},
      # out: {"transition ease-in duration-100", "opacity-100", "opacity-0"}
    )
  end
end
