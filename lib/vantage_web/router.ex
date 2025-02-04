defmodule VantageWeb.Router do
  use VantageWeb, :router

  import VantageWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {VantageWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", VantageWeb do
    pipe_through :browser

    get "/", PageController, :home
  end

  # Other scopes may use custom stacks.
  # scope "/api", VantageWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:vantage, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: VantageWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  scope "/", VantageWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    live_session :redirect_if_user_is_authenticated,
      on_mount: [{VantageWeb.UserAuth, :redirect_if_user_is_authenticated}] do
      live "/users/register", UserRegistrationLive, :new
      live "/users/log_in", UserLoginLive, :new
      live "/users/reset_password", UserForgotPasswordLive, :new
      live "/users/reset_password/:token", UserResetPasswordLive, :edit
    end

    post "/users/log_in", UserSessionController, :create
  end

  scope "/", VantageWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{VantageWeb.UserAuth, :ensure_authenticated}] do
      live "/investigations", InvestigationLive.Index, :index
      live "/investigations/new", InvestigationLive.Index, :new
      live "/investigations/:id/edit", InvestigationLive.Index, :edit

      live "/investigations/:id", InvestigationLive.Show, :show
      live "/investigations/:id/show/edit", InvestigationLive.Show, :edit

      live "/investigation_collaborators", InvestigationCollaboratorLive.Index, :index
      live "/investigation_collaborators/new", InvestigationCollaboratorLive.Index, :new
      live "/investigation_collaborators/:id/edit", InvestigationCollaboratorLive.Index, :edit

      live "/investigation_collaborators/:id", InvestigationCollaboratorLive.Show, :show
      live "/investigation_collaborators/:id/show/edit", InvestigationCollaboratorLive.Show, :edit

      live "/projections", ProjectionLive.Index, :index
      live "/projections/new", ProjectionLive.Index, :new
      live "/projections/:id/edit", ProjectionLive.Index, :edit

      live "/projections/:id", ProjectionLive.Show, :show
      live "/projections/:id/show/edit", ProjectionLive.Show, :edit

      live "/keyframes", KeyframeLive.Index, :index
      live "/keyframes/new", KeyframeLive.Index, :new
      live "/keyframes/:id/edit", KeyframeLive.Index, :edit

      live "/keyframes/:id", KeyframeLive.Show, :show
      live "/keyframes/:id/show/edit", KeyframeLive.Show, :edit

      live "/models", ModelLive.Index, :index
      live "/models/new", ModelLive.Index, :new
      live "/models/:id/edit", ModelLive.Index, :edit

      live "/models/:id", ModelLive.Show, :show
      live "/models/:id/show/edit", ModelLive.Show, :edit

      live "/users/settings", UserSettingsLive, :edit
      live "/users/settings/confirm_email/:token", UserSettingsLive, :confirm_email
    end
  end

  scope "/", VantageWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete

    live_session :current_user,
      on_mount: [{VantageWeb.UserAuth, :mount_current_user}] do
      live "/users/confirm/:token", UserConfirmationLive, :edit
      live "/users/confirm", UserConfirmationInstructionsLive, :new
    end
  end
end
