defmodule TradeMonitor.TradeStoreTest do
  use ExUnit.Case, async: false

  alias TradeMonitor.{Trade, TradeStore}

  setup do
    start_supervised!(TradeStore)
    TradeStore.reset()
    :ok
  end

  test "records trades and anomalies" do
    trade = %Trade{
      id: "t1",
      symbol: "AAPL",
      price: 100.0,
      quantity: 5,
      timestamp: DateTime.utc_now(),
      venue: "NYSE",
      side: "buy",
      notional: 500.0
    }

    TradeStore.record_trade(trade)
    TradeStore.record_anomaly(trade, ["test_reason"])

    assert TradeStore.trade_count() == 1
    assert TradeStore.anomaly_count() == 1

    [entry] = TradeStore.list_anomalies()
    assert entry.reasons == ["test_reason"]
  end
end
