defmodule TradeMonitor.JSONTest do
  use ExUnit.Case, async: true

  alias TradeMonitor.JSON

  test "decodes objects and arrays" do
    json = "{\"name\":\"trade\",\"values\":[1,2,3],\"ok\":true,\"nil\":null}"

    assert {:ok, %{"name" => "trade", "values" => [1.0, 2.0, 3.0], "ok" => true, "nil" => nil}} =
             JSON.decode(json)
  end

  test "decodes numbers" do
    assert {:ok, 42.0} = JSON.decode("42")
    assert {:ok, -13.5} = JSON.decode("-13.5")
    assert {:ok, 1.2e3} = JSON.decode("1.2e3")
  end

  test "decodes strings with escapes" do
    assert {:ok, "hello\nworld"} = JSON.decode("\"hello\\nworld\"")
    assert {:ok, "snowman ☃"} = JSON.decode("\"snowman \\u2603\"")
  end

  test "rejects invalid JSON" do
    assert {:error, _} = JSON.decode("{bad}")
    assert {:error, _} = JSON.decode("[1,2,]")
  end
end
