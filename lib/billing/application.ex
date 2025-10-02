defmodule Billing.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      BillingWeb.Telemetry,
      Billing.Repo,
      {DNSCluster, query: Application.get_env(:billing, :dns_cluster_query) || :ignore},
      {Oban, Application.fetch_env!(:billing, Oban)},
      {Phoenix.PubSub, name: Billing.PubSub},
      # Start a worker by calling: Billing.Worker.start_link(arg)
      # {Billing.Worker, arg},
      # Start to serve requests, typically the last entry
      BillingWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Billing.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    BillingWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
