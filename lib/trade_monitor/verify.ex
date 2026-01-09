defmodule TradeMonitor.Verify do
  @moduledoc """
  Entry point for deterministic verification.
  """

  alias TradeMonitor.{Monitor, TradeStore}

  def run do
    {:ok, _} = Application.ensure_all_started(:trade_monitor)
    results = Monitor.run_once()

    IO.puts("Trades processed: #{results.trades}")
    IO.puts("Anomalies detected: #{results.anomalies}")

    Enum.each(results.errors, fn error ->
      IO.puts("Error: #{error}")
    end)

    cond do
      results.trades == 0 ->
        IO.puts("Verification failed: no trades processed")
        exit({:shutdown, 1})

      results.errors != [] ->
        IO.puts("Verification failed: errors encountered")
        exit({:shutdown, 1})

      TradeStore.anomaly_count() == 0 ->
        IO.puts("Verification failed: expected anomalies")
        exit({:shutdown, 1})

      true ->
        IO.puts("Verification succeeded")
        :ok
    end
  end
end
