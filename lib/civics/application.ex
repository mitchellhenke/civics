defmodule Civics.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    Civics.Release.migrate()

    children = [
      CivicsWeb.Telemetry,
      Civics.Repo,
      {DNSCluster, query: Application.get_env(:civics, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Civics.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Civics.Finch},
      # Start a worker by calling: Civics.Worker.start_link(arg)
      # {Civics.Worker, arg},
      # Start to serve requests, typically the last entry
      CivicsWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Civics.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    CivicsWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
