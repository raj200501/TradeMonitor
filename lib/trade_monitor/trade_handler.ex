defmodule TradeMonitor.TradeHandler do
  use GenServer

  @trade_source Application.get_env(:trade_monitor, :trade_source)

  def start_link(_args) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_state) do
    schedule_trade_read()
    {:ok, []}
  end

  def handle_info(:read_trades, state) do
    trades = read_trades()
    Enum.each(trades, fn trade -> TradeMonitor.TradeAnalyzer.analyze_trade(trade) end)
    schedule_trade_read()
    {:noreply, state}
  end

  defp schedule_trade_read do
    Process.send_after(self(), :read_trades, 5000)
  end

  defp read_trades do
    @trade_source
    |> File.read!()
    |> Jason.decode!()
  end
end
