defmodule Q.Application do
  @moduledoc false
  use Application

  def start(_type, _args) do
    children = [Q.Repo, QWeb.Telemetry, {Phoenix.PubSub, name: Q.PubSub}, QWeb.EndPoint]
    opts = [strategy: :one_for_one, name: Q.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    QWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
