import Config

if config_env() in [:dev, :test, :prod] do
  parse_float = fn value ->
    case Float.parse(value) do
      {float, _rest} -> float
      :error -> value |> String.to_integer() |> Kernel.*(1.0)
    end
  end

  config :trade_monitor,
    trade_source:
      System.get_env("TRADE_SOURCE", Application.fetch_env!(:trade_monitor, :trade_source)),
    anomaly_threshold: System.get_env("ANOMALY_THRESHOLD", "1000") |> parse_float.(),
    max_retries: System.get_env("MAX_RETRIES", "5") |> String.to_integer(),
    poll_interval_ms: System.get_env("POLL_INTERVAL_MS", "2000") |> String.to_integer(),
    allowed_symbols:
      System.get_env("ALLOWED_SYMBOLS", "AAPL,MSFT,TSLA,AMZN,NVDA")
      |> String.split(",", trim: true),
    max_quantity: System.get_env("MAX_QUANTITY", "10000") |> String.to_integer(),
    max_notional: System.get_env("MAX_NOTIONAL", "25000000") |> parse_float.(),
    price_deviation_pct: System.get_env("PRICE_DEVIATION_PCT", "0.15") |> parse_float.()
end
