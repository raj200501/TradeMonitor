defmodule TradeMonitor.Supervisor do
  use Supervisor

  def start_link(_args) do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    children = [
      {TradeMonitor.TradeStore, []},
      {TradeMonitor.TradeAnalyzer, []},
      {TradeMonitor.TradeHandler, []}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
