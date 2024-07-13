defmodule TradeMonitor.TradeAnalyzer do
  use GenServer

  @anomaly_threshold Application.get_env(:trade_monitor, :anomaly_threshold)

  def start_link(_args) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_state) do
    {:ok, []}
  end

  def analyze_trade(trade) do
    GenServer.cast(__MODULE__, {:analyze, trade})
  end

  def handle_cast({:analyze, trade}, state) do
    if trade["value"] > @anomaly_threshold do
      IO.puts("Anomaly detected: #{inspect(trade)}")
    end
    {:noreply, state}
  end
end
