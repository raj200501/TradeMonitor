defmodule TradeMonitor.MonitorTest do
  use ExUnit.Case, async: false

  alias TradeMonitor.{Monitor, TradeAnalyzer, TradeStore}
  alias TradeMonitor.TestFixtures

  setup do
    previous = TestFixtures.capture_env(:trade_monitor)

    Application.put_env(:trade_monitor, :trade_source, TestFixtures.fixture_path("trades.json"))

    on_exit(fn ->
      TestFixtures.restore_env(:trade_monitor, previous)
    end)

    start_supervised!(TradeStore)
    start_supervised!(TradeAnalyzer)
    :ok
  end

  test "runs a single monitoring pass" do
    results = Monitor.run_once()

    assert results.trades == 6
    assert results.anomalies > 0
    assert results.errors == []
  end
end
