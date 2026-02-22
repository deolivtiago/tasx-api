defmodule TasxCore.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      TasxWeb.Telemetry,
      TasxCore.Repo,
      {DNSCluster, query: Application.get_env(:tasx, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: TasxCore.PubSub},
      # Start a worker by calling: TasxCore.Worker.start_link(arg)
      # {TasxCore.Worker, arg},
      # Start to serve requests, typically the last entry
      TasxWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: TasxCore.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    TasxWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
