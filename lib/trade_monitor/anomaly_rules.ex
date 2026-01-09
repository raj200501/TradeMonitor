defmodule TradeMonitor.AnomalyRules do
  @moduledoc """
  Pure anomaly rule checks for trades.
  """

  alias TradeMonitor.{Config, Trade}

  @type reason :: String.t()

  @spec evaluate(Trade.t(), Config.t(), map()) :: [reason()]
  def evaluate(%Trade{} = trade, %Config{} = config, market_state) do
    []
    |> check_threshold(trade, config)
    |> check_quantity(trade, config)
    |> check_notional(trade, config)
    |> check_symbol(trade, config)
    |> check_price_deviation(trade, config, market_state)
  end

  defp check_threshold(reasons, trade, config) do
    if trade.price * trade.quantity > config.anomaly_threshold do
      ["notional_above_threshold" | reasons]
    else
      reasons
    end
  end

  defp check_quantity(reasons, trade, config) do
    if trade.quantity > config.max_quantity do
      ["quantity_above_limit" | reasons]
    else
      reasons
    end
  end

  defp check_notional(reasons, trade, config) do
    if trade.notional > config.max_notional do
      ["notional_above_limit" | reasons]
    else
      reasons
    end
  end

  defp check_symbol(reasons, trade, config) do
    if trade.symbol in config.allowed_symbols do
      reasons
    else
      ["symbol_not_allowed" | reasons]
    end
  end

  defp check_price_deviation(reasons, trade, config, market_state) do
    case Map.fetch(market_state, trade.symbol) do
      {:ok, avg_price} ->
        deviation = abs(trade.price - avg_price) / avg_price

        if deviation > config.price_deviation_pct do
          ["price_deviation" | reasons]
        else
          reasons
        end

      :error ->
        reasons
    end
  end
end
