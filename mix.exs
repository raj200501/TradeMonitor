defmodule TradeMonitor.MixProject do
  use Mix.Project

  def project do
    [
      app: :trade_monitor,
      version: "0.1.0",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {TradeMonitor.Application, []}
    ]
  end

  defp deps do
    [
      {:jason, "~> 1.2"}
    ]
  end
end
