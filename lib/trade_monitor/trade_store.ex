defmodule TradeMonitor.TradeStore do
  @moduledoc """
  Stores trade activity and anomalies in ETS for quick access.
  """

  use GenServer

  @trades_table :trade_monitor_trades
  @anomalies_table :trade_monitor_anomalies

  def start_link(_args) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def init(state) do
    :ets.new(@trades_table, [:named_table, :set, :public])
    :ets.new(@anomalies_table, [:named_table, :bag, :public])
    {:ok, state}
  end

  def record_trade(trade) do
    :ets.insert(@trades_table, {trade.id, trade})
    :ok
  end

  def record_anomaly(trade, reasons) do
    :ets.insert(@anomalies_table, {trade.id, trade, reasons})
    :ok
  end

  def trade_count do
    :ets.info(@trades_table, :size)
  end

  def anomaly_count do
    :ets.info(@anomalies_table, :size)
  end

  def list_anomalies do
    :ets.tab2list(@anomalies_table)
    |> Enum.map(fn {_id, trade, reasons} -> %{trade: trade, reasons: reasons} end)
  end

  def reset do
    :ets.delete_all_objects(@trades_table)
    :ets.delete_all_objects(@anomalies_table)
    :ok
  end
end
