defmodule Cloudserver.NodePinger do
  use GenServer
  require Logger
  ## Client API

  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  ## Server Callbacks

  def init(:ok) do
    Process.send_after(self(), {:join_remote_nodes}, 10000)
    {:ok, %{}}
  end

  def handle_info({:join_remote_nodes}, _state) do
    now = :os.system_time()
    # Logger.info("Now is #{now}")
    joined_nodes = join_remote_nodes()
    Logger.info("Pinged nodes #{inspect(joined_nodes)}")
    Process.send_after(self(), {:join_remote_nodes}, 20000)
    {:noreply, %{:time_pinged => now, :joined_nodes => joined_nodes}}
  end

  def handle_info(msg, state) do
    Logger.info("Msg received is #{inspect(msg)}")
    {:noreply, state}
  end

  ## Private functions

  # :lasp_peer_service.members()
  def join_remote_nodes() do
    Logger.info "Attempting to join remote nodes"
    Logger.info "Connected node list is #{inspect Node.list} and I am #{inspect Node.self}"
    Logger.info("[Partisan] I am: #{inspect :partisan_peer_service_manager.myself}")
    Logger.info "[Partisan] Cluster membership is: #{inspect :lasp_peer_service.members()}"
    remote_nodes_list = Application.get_env(:cloudserver, :remote_hosts, [])
    Logger.info "Remote nodes: #{inspect remote_nodes_list}"
    for remote_node <- remote_nodes_list, Node.connect(String.to_atom(remote_node)) == true, do: fn remote_node ->
      Logger.info "Trying to join remote node #{inspect remote_node}"
      remote_node_partisan_myself = :rpc.call(String.to_atom(remote_node), :partisan_hyparview_peer_service_manager, :myself, [])
      Logger.info "Remote node #{inspect remote_node_partisan_myself}"
      remote_listen_addrs = remote_node_partisan_myself[:listen_addrs]
      new_listen_addrs =  %{hd(remote_listen_addrs) | ip: get_remote_ip(String.to_atom(remote_node))}
      new_remote = %{remote_node_partisan_myself | listen_addrs: [new_listen_addrs]}
      Logger.info "New remote node config #{inspect new_remote}"
      :lasp_peer_service.join(new_remote)
      Logger.info "Joined #{remote_node}"
      remote_node
    end.(remote_node)
  end
  

  def get_remote_ip(remote_name) do
    remote_nodes = %{
      :'server1@ec2-18-185-18-147.eu-central-1.compute.amazonaws.com' => {18,185,18,147},
      :'server2@ec2-18-130-232-107.eu-west-2.compute.amazonaws.com' => {18,130,232,107},
      :'server3@ec2-35-180-138-155.eu-west-3.compute.amazonaws.com' => {35,180,138,155}
    }
    remote_nodes[remote_name]

  end
end
