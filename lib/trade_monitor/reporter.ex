defmodule TradeMonitor.Reporter do
  @moduledoc """
  Outputs trade monitoring events to standard output.
  """

  alias TradeMonitor.Trade

  def report_trade(%Trade{} = trade) do
    IO.puts("Trade processed: #{trade_summary(trade)}")
  end

  def report_anomaly(%Trade{} = trade, reasons) do
    IO.puts("Anomaly detected: #{trade_summary(trade)} reasons=#{Enum.join(reasons, ",")}")
  end

  def trade_summary(%Trade{} = trade) do
    "id=#{trade.id} symbol=#{trade.symbol} price=#{trade.price} qty=#{trade.quantity} notional=#{trade.notional}"
  end
end
