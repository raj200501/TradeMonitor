defmodule TradeMonitor.Application do
  use Application

  def start(_type, _args) do
    children = [
      {TradeMonitor.Supervisor, []}
    ]

    opts = [strategy: :one_for_one, name: TradeMonitor.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
