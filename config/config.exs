use Mix.Config

config :trade_monitor,
  trade_source: "trades.json",
  anomaly_threshold: 1000,
  max_retries: 5
