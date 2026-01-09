import Config

config :trade_monitor,
  trade_source: "data/trades.json",
  anomaly_threshold: 1000.0,
  max_retries: 5,
  poll_interval_ms: 2_000,
  allowed_symbols: ["AAPL", "MSFT", "TSLA", "AMZN", "NVDA"],
  max_quantity: 10_000,
  max_notional: 25_000_000.0,
  price_deviation_pct: 0.15
