defmodule TradeMonitor.TradeHandlerTest do
  use ExUnit.Case, async: false

  import ExUnit.CaptureLog

  alias TradeMonitor.{TradeAnalyzer, TradeHandler, TradeStore}
  alias TradeMonitor.TestFixtures

  setup do
    previous = TestFixtures.capture_env(:trade_monitor)

    Application.put_env(:trade_monitor, :trade_source, TestFixtures.fixture_path("trades.json"))

    on_exit(fn ->
      TestFixtures.restore_env(:trade_monitor, previous)
    end)

    start_supervised!(TradeStore)
    start_supervised!(TradeAnalyzer)

    TradeStore.reset()
    :ok
  end

  test "reads trades and forwards to analyzer" do
    {:ok, state} = TradeHandler.init([])

    capture_log(fn ->
      TradeHandler.handle_info(:read_trades, state)
      Process.sleep(50)
    end)

    assert TradeStore.trade_count() == 6
    assert TradeStore.anomaly_count() > 0
  end
end
