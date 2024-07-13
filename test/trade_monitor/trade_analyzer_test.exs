defmodule TradeMonitor.TradeAnalyzerTest do
  use ExUnit.Case

  test "detects anomalies" do
    trade = %{"value" => 2000}
    assert capture_io(fn ->
      TradeMonitor.TradeAnalyzer.analyze_trade(trade)
    end) =~ "Anomaly detected"
  end
end
