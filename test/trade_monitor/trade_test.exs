defmodule TradeMonitor.TradeTest do
  use ExUnit.Case, async: true

  alias TradeMonitor.Trade

  test "builds trade from map" do
    payload = %{
      "id" => "t1",
      "symbol" => "AAPL",
      "price" => 150.25,
      "quantity" => 10,
      "timestamp" => "2024-01-01T10:00:00Z",
      "venue" => "NYSE",
      "side" => "buy"
    }

    assert {:ok, trade} = Trade.from_map(payload)
    assert trade.id == "t1"
    assert trade.notional == 1502.5
  end

  test "returns error for missing fields" do
    assert {:error, reason} = Trade.from_map(%{"id" => "t1"})
    assert reason =~ "Missing fields"
  end

  test "returns error for invalid price" do
    payload = %{
      "id" => "t1",
      "symbol" => "AAPL",
      "price" => "bad",
      "quantity" => 10,
      "timestamp" => "2024-01-01T10:00:00Z"
    }

    assert {:error, "Invalid price"} = Trade.from_map(payload)
  end
end
