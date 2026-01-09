defmodule TradeMonitor.Monitor do
  @moduledoc """
  Provides imperative helpers for single-pass monitoring runs.
  """

  alias TradeMonitor.{Config, TradeAnalyzer, TradeSource, TradeStore}

  def run_once do
    config = Config.load()

    TradeStore.reset()

    case TradeSource.load(config.trade_source) do
      {:ok, trades, errors} ->
        Enum.each(trades, &TradeAnalyzer.analyze_trade_sync/1)
        %{trades: length(trades), errors: errors, anomalies: TradeStore.anomaly_count()}

      {:error, reason} ->
        %{trades: 0, errors: [reason], anomalies: 0}
    end
  end
end
