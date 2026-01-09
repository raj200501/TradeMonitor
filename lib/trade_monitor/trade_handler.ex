defmodule TradeMonitor.TradeHandler do
  @moduledoc """
  Periodically reads trades from the configured source and forwards them.
  """

  use GenServer

  require Logger

  alias TradeMonitor.{Config, TradeAnalyzer, TradeSource}

  def start_link(_args) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_state) do
    config = Config.load()
    schedule_trade_read(config.poll_interval_ms)
    {:ok, %{config: config}}
  end

  def handle_info(:read_trades, %{config: config} = state) do
    case TradeSource.load(config.trade_source) do
      {:ok, trades, errors} ->
        Enum.each(trades, &TradeAnalyzer.analyze_trade/1)
        Enum.each(errors, &log_error/1)

      {:error, reason} ->
        log_error(reason)
    end

    schedule_trade_read(config.poll_interval_ms)
    {:noreply, state}
  end

  defp schedule_trade_read(interval_ms) do
    Process.send_after(self(), :read_trades, interval_ms)
  end

  defp log_error(reason) do
    Logger.warning("Trade source error: #{reason}")
  end
end
