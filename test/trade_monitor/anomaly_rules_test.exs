defmodule TradeMonitor.AnomalyRulesTest do
  use ExUnit.Case, async: true

  alias TradeMonitor.{AnomalyRules, Config, Trade}

  test "flags rule violations" do
    config = %Config{
      trade_source: "data/trades.json",
      anomaly_threshold: 1000.0,
      max_retries: 1,
      poll_interval_ms: 1000,
      allowed_symbols: ["AAPL"],
      max_quantity: 10,
      max_notional: 5000.0,
      price_deviation_pct: 0.1
    }

    trade = %Trade{
      id: "t1",
      symbol: "BAD",
      price: 200.0,
      quantity: 100,
      timestamp: DateTime.utc_now(),
      venue: "NYSE",
      side: "buy",
      notional: 20_000.0
    }

    reasons = AnomalyRules.evaluate(trade, config, %{"BAD" => 50.0})

    assert "quantity_above_limit" in reasons
    assert "notional_above_limit" in reasons
    assert "symbol_not_allowed" in reasons
    assert "price_deviation" in reasons
  end
end
