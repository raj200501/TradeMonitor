defmodule TradeMonitor.ConfigTest do
  use ExUnit.Case, async: false

  alias TradeMonitor.Config
  alias TradeMonitor.TestFixtures

  setup do
    previous = TestFixtures.capture_env(:trade_monitor)

    on_exit(fn ->
      TestFixtures.restore_env(:trade_monitor, previous)
    end)

    :ok
  end

  test "loads config from application env" do
    Application.put_env(:trade_monitor, :trade_source, "data/trades.json")
    Application.put_env(:trade_monitor, :anomaly_threshold, 1000.0)
    Application.put_env(:trade_monitor, :max_retries, 3)
    Application.put_env(:trade_monitor, :poll_interval_ms, 500)
    Application.put_env(:trade_monitor, :allowed_symbols, ["AAPL"])
    Application.put_env(:trade_monitor, :max_quantity, 500)
    Application.put_env(:trade_monitor, :max_notional, 10_000.0)
    Application.put_env(:trade_monitor, :price_deviation_pct, 0.1)

    config = Config.load()

    assert config.trade_source == "data/trades.json"
    assert config.anomaly_threshold == 1000.0
    assert config.allowed_symbols == ["AAPL"]
  end

  test "rejects invalid configuration" do
    Application.put_env(:trade_monitor, :trade_source, "")
    Application.put_env(:trade_monitor, :anomaly_threshold, -1)
    Application.put_env(:trade_monitor, :max_retries, 0)
    Application.put_env(:trade_monitor, :poll_interval_ms, 0)
    Application.put_env(:trade_monitor, :allowed_symbols, [])
    Application.put_env(:trade_monitor, :max_quantity, -5)
    Application.put_env(:trade_monitor, :max_notional, -10.0)
    Application.put_env(:trade_monitor, :price_deviation_pct, 2.0)

    assert_raise ArgumentError, fn ->
      Config.load()
    end
  end
end
