defmodule Vantage.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      VantageWeb.Telemetry,
      Vantage.Repo,
      {DNSCluster, query: Application.get_env(:vantage, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Vantage.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Vantage.Finch},
      # Start a worker by calling: Vantage.Worker.start_link(arg)
      # {Vantage.Worker, arg},
      # Start to serve requests, typically the last entry
      VantageWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Vantage.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    VantageWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
