defmodule Cloudserver.NodeClient do
  use GenServer
  require Logger

  ## Client API

  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def store_data(source_node, data_type, data) do
    GenServer.call(__MODULE__, {:store_data, source_node, data_type, data})
  end


  ## Server Callbacks

  def init(:ok) do
    Logger.info "Starting the node client api endpoint gen server"
    {:ok, %{:nodes_discovered => []}}
  end

  def handle_call({:store_data, source_node, data_type, source_data}, _from, state) do
    Logger.info "from #{inspect source_node}"
    state = case Enum.find(state[:nodes_discovered], fn node -> node == source_node end ) do
      nil ->
        Logger.info "#{inspect source_node} was not in the discovered nodes list -> adding"
        %{:nodes_discovered => state[:nodes_discovered] ++ [source_node]}
      _ -> state
    end

    {:ok, data_crdt} = :lasp.query({<<"data">>, :state_orset})
    data_list = :sets.to_list(data_crdt)
    Logger.info "Dataset is #{inspect data_list}"

    if !Enum.any?(data_list) do
      Logger.info "CRDT does not exist -> creating (#{inspect %{source_node => %{data_type => source_data}}})"
      :lasp.update({<<"data">>, :state_orset}, {:add, %{source_node => %{data_type => source_data}}}, :self)
    else
      data = hd(data_list)
      updated_data = case Map.has_key?(data, source_node) do
        false ->
          Logger.info "#{inspect source_node} is not present in CRDT -> adding"
          Map.put(data, source_node , %{data_type => source_data})
        true ->
          Logger.info "#{inspect source_node} present in CRDT -> adding or appending data"
          Map.put(data, source_node, Map.update(data[source_node], data_type, source_data,
          fn existing_value ->
            existing_value ++ source_data
          end))
      end
      :lasp.update({<<"data">>, :state_orset}, {:rmv, data}, :self)
      :lasp.update({<<"data">>, :state_orset}, {:add, updated_data}, :self)
      Logger.info "New dataset is #{inspect updated_data}"
    end

    {:reply, :ok, state}
  end


  def handle_info(msg, state) do
    IO.puts("Msg received is #{inspect(msg)}")
    {:noreply, state}
  end



end
