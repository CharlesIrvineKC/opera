defmodule Opera.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      OperaWeb.Telemetry,
      Opera.Repo,
      {Oban, Application.fetch_env!(:opera, Oban)},
      {DNSCluster, query: Application.get_env(:opera, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Opera.PubSub},
      {Finch, name: Opera.Finch},
      Opera.Admin,
      OperaWeb.Endpoint
    ]

    opts = [strategy: :one_for_one, name: Opera.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @impl true
  def config_change(changed, _new, removed) do
    OperaWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
