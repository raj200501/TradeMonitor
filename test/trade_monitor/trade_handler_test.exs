defmodule TradeMonitor.TradeHandlerTest do
  use ExUnit.Case
  import ExUnit.CaptureIO

  test "reads and processes trades" do
    capture_io(fn ->
      TradeMonitor.TradeHandler.handle_info(:read_trades, [])
    end) |> IO.puts()
  end
end
