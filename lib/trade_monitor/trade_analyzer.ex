defmodule TradeMonitor.TradeAnalyzer do
  @moduledoc """
  GenServer that evaluates trades and stores results.
  """

  use GenServer

  alias TradeMonitor.{AnomalyDetector, Config, Reporter, Trade, TradeStore}

  def start_link(_args) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def analyze_trade(%Trade{} = trade) do
    GenServer.cast(__MODULE__, {:analyze, trade})
  end

  def analyze_trade_sync(%Trade{} = trade) do
    GenServer.call(__MODULE__, {:analyze_sync, trade})
  end

  def init(_state) do
    config = Config.load()
    {:ok, %{config: config, market_state: %{}}}
  end

  def handle_cast({:analyze, %Trade{} = trade}, state) do
    {:noreply, process_trade(trade, state)}
  end

  def handle_call({:analyze_sync, %Trade{} = trade}, _from, state) do
    next_state = process_trade(trade, state)
    {:reply, :ok, next_state}
  end

  defp process_trade(%Trade{} = trade, %{config: config, market_state: market_state} = state) do
    {reasons, next_state} = AnomalyDetector.evaluate(trade, config, market_state)

    TradeStore.record_trade(trade)

    if reasons != [] do
      TradeStore.record_anomaly(trade, reasons)
      Reporter.report_anomaly(trade, reasons)
    else
      Reporter.report_trade(trade)
    end

    %{state | market_state: next_state}
  end
end
