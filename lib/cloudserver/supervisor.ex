defmodule Cloudserver.Supervisor do
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, :ok, opts)
  end

  def init(:ok) do

    # Supervisor.init(children, strategy: :one_for_one)
    children = case mode() do
        :computation_only ->
            [
                {Cloudserver.Regression, name: Cloudserver.Regression}
            ]
        :full ->
            [
                {Cloudserver.NodePinger, name: Cloudserver.NodePinger},
                {Cloudserver.NodeClient, name: Cloudserver.NodeClient},
                {Cloudserver.Regression, name: Cloudserver.Regression}
            ]
        :server ->
            [
                {Cloudserver.NodePinger, name: Cloudserver.NodePinger},
                {Cloudserver.NodeClient, name: Cloudserver.NodeClient}
            ]
        _ ->
            []
    end

    Supervisor.init(children, strategy: :one_for_one)
  end

  def mode do
    Application.get_env(:cloudserver, :mode)
  end

end
