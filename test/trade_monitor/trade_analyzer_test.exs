defmodule TradeMonitor.TradeAnalyzerTest do
  use ExUnit.Case, async: false

  alias TradeMonitor.{TradeAnalyzer, TradeStore, Trade}

  setup do
    start_supervised!(TradeStore)
    start_supervised!(TradeAnalyzer)
    TradeStore.reset()
    :ok
  end

  test "records anomalies and market state" do
    trade = %Trade{
      id: "t1",
      symbol: "AAPL",
      price: 500.0,
      quantity: 20,
      timestamp: DateTime.utc_now(),
      venue: "NYSE",
      side: "buy",
      notional: 10_000.0
    }

    TradeAnalyzer.analyze_trade(trade)
    Process.sleep(50)

    assert TradeStore.trade_count() == 1
    assert TradeStore.anomaly_count() == 1
  end
end
