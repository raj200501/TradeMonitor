defmodule TradeMonitor.FaultTolerantWorkerTest do
  use ExUnit.Case

  test "retries processing until success" do
    {:ok, pid} = TradeMonitor.FaultTolerantWorker.start_link(100)
    assert GenServer.call(pid, :process) == :ok
  end
end
