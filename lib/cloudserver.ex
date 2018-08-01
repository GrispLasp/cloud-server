defmodule Cloudserver do
  use Application
  require Logger

  def start(_type, _args) do

    Logger.info("Started application")

    Logger.info("#{inspect :net_adm.names()}")
    Logger.info("#{inspect :net_adm.localhost()}")
    Logger.info("#{inspect Node.self()}")
    Logger.info("#{inspect Node.get_cookie()}")


    # :node_generic_tasks_server.add_task({:task1, :all, fn ->
    #   IO.puts "hello all"
    #   :timer.sleep(1000)
    #  end})



    children = [
      {Plug.Adapters.Cowboy2, scheme: :http, plug: Cloudserver.Router, options: [port: port()]}
    ]


    Cloudserver.Supervisor.start_link(name: Cloudserver.Supervisor)

    Supervisor.start_link(children, strategy: :one_for_one)
  end

  def port do
    Application.get_env(:cloudserver, :port)
  end
end
