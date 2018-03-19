defmodule Campbot.Bot.Subscribers do
  use GenServer

  @me __MODULE__
  @subscriber_table_name :subscribers

  def start_link do
    GenServer.start_link(
      @me,
      [{:subscriber_table_name, @subscriber_table_name}],
      name: @me)
  end

  def add(subscriber_id) do
    GenServer.call(@me, {:add, subscriber_id})
  end

  def delete(subscriber_id) do
    GenServer.call(@me, {:delete, subscriber_id})
  end

  def get_all() do
    GenServer.call(@me, {:get_all})
  end

  # GenServer callbacks

  def handle_call({:add, subscriber_id}, _from, state) do
    %{ets_table_name: ets_table_name} = state
    subscribers = lookup_subscribers(state)
    result = :dets.insert(ets_table_name, {:subscribers, MapSet.put(subscribers, subscriber_id)})
    {:reply, result, state}
  end

  def handle_call({:get_all}, _from, state) do
    subscribers = lookup_subscribers(state) |> MapSet.to_list()
    {:reply, subscribers, state}
  end

  def handle_call({:delete, subscriber_id}, _from, state) do
    %{ets_table_name: ets_table_name} = state

    filtered_subscribers = lookup_subscribers(state)
    |> Enum.filter(&(&1 != subscriber_id))
    |> Enum.into(MapSet.new)

    :dets.delete(ets_table_name, :subscribers)
    :dets.insert(ets_table_name, {:subscribers, filtered_subscribers})

    {:reply, subscriber_id, state}
  end

  def init(args) do
    [{:subscriber_table_name, ets_table_name}] = args
    :dets.open_file(ets_table_name, [type: :set])
    {:ok, %{ets_table_name: ets_table_name}}
  end

  defp lookup_subscribers(state) do
    %{ets_table_name: ets_table_name} = state
    case :dets.lookup(ets_table_name, :subscribers) do
      [{:subscribers, subscribers}] -> subscribers
      [] -> MapSet.new()
    end
  end
end
