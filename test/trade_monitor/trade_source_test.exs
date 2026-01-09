defmodule TradeMonitor.TradeSourceTest do
  use ExUnit.Case, async: true

  alias TradeMonitor.{TradeSource, Trade}
  alias TradeMonitor.TestFixtures

  test "loads JSON array trades" do
    path = TestFixtures.fixture_path("trades.json")
    {:ok, trades, errors} = TradeSource.load(path)

    assert errors == []
    assert length(trades) == 6
    assert %Trade{id: "t1", symbol: "AAPL"} = hd(trades)
  end

  test "loads JSONL trades" do
    path = TestFixtures.fixture_path("trades.jsonl")
    {:ok, trades, errors} = TradeSource.load(path)

    assert errors == []
    assert Enum.any?(trades, &(&1.symbol == "BAD"))
  end

  test "returns error for missing file" do
    assert {:error, reason} = TradeSource.load("missing.json")
    assert reason =~ "Failed to load"
  end
end
