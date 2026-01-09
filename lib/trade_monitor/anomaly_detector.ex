defmodule TradeMonitor.AnomalyDetector do
  @moduledoc """
  Evaluates trades against anomaly rules and maintains rolling averages.
  """

  alias TradeMonitor.{AnomalyRules, Config, Trade}

  @type market_state :: %{optional(String.t()) => float()}

  def evaluate(%Trade{} = trade, %Config{} = config, market_state) do
    reasons = AnomalyRules.evaluate(trade, config, market_state)
    {reasons, update_market_state(trade, market_state)}
  end

  def update_market_state(%Trade{} = trade, market_state) do
    Map.update(market_state, trade.symbol, trade.price, fn existing ->
      existing * 0.9 + trade.price * 0.1
    end)
  end
end
