defmodule TradeMonitor.FaultTolerantWorker do
  use GenServer

  @max_retries Application.get_env(:trade_monitor, :max_retries)

  def start_link(initial_value) do
    GenServer.start_link(__MODULE__, initial_value, name: __MODULE__)
  end

  def init(initial_value) do
    {:ok, %{value: initial_value, retries: 0}}
  end

  def handle_call(:process, _from, %{value: value, retries: retries} = state) when retries < @max_retries do
    case process(value) do
      :ok ->
        {:reply, :ok, %{state | retries: 0}}
      :error ->
        {:reply, :error, %{state | retries: retries + 1}}
    end
  end

  def handle_call(:process, _from, state) do
    {:reply, :give_up, state}
  end

  defp process(value) do
    # Simulate a process that may fail
    if :rand.uniform(10) > 2 do
      IO.puts("Processed value: #{value}")
      :ok
    else
      IO.puts("Failed to process value: #{value}")
      :error
    end
  end
end
