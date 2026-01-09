defmodule TradeMonitor.FaultTolerantWorkerTest do
  use ExUnit.Case, async: true

  alias TradeMonitor.FaultTolerantWorker

  test "retries processing until success" do
    parent = self()

    process_fun = fn value ->
      send(parent, {:attempt, value})

      case Process.get(:attempts, 0) do
        0 ->
          Process.put(:attempts, 1)
          :error

        1 ->
          Process.put(:attempts, 2)
          :error

        _ ->
          :ok
      end
    end

    {:ok, pid} = FaultTolerantWorker.start_link(value: 100, process_fun: process_fun)

    assert FaultTolerantWorker.process(pid) == :error
    assert FaultTolerantWorker.process(pid) == :error
    assert FaultTolerantWorker.process(pid) == :ok

    assert_receive {:attempt, 100}
  end
end
