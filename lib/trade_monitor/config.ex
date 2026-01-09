defmodule TradeMonitor.Config do
  @moduledoc """
  Loads and validates runtime configuration for TradeMonitor.
  """

  @enforce_keys [
    :trade_source,
    :anomaly_threshold,
    :max_retries,
    :poll_interval_ms,
    :allowed_symbols,
    :max_quantity,
    :max_notional,
    :price_deviation_pct
  ]
  defstruct @enforce_keys

  @type t :: %__MODULE__{
          trade_source: String.t(),
          anomaly_threshold: float(),
          max_retries: non_neg_integer(),
          poll_interval_ms: non_neg_integer(),
          allowed_symbols: [String.t()],
          max_quantity: pos_integer(),
          max_notional: float(),
          price_deviation_pct: float()
        }

  def load do
    config = Application.get_all_env(:trade_monitor)

    %__MODULE__{
      trade_source: fetch!(config, :trade_source),
      anomaly_threshold: fetch_float!(config, :anomaly_threshold),
      max_retries: fetch_integer!(config, :max_retries),
      poll_interval_ms: fetch_integer!(config, :poll_interval_ms),
      allowed_symbols: fetch_list!(config, :allowed_symbols),
      max_quantity: fetch_integer!(config, :max_quantity),
      max_notional: fetch_float!(config, :max_notional),
      price_deviation_pct: fetch_float!(config, :price_deviation_pct)
    }
    |> validate()
  end

  def validate(%__MODULE__{} = config) do
    errors =
      []
      |> validate_path(config.trade_source)
      |> validate_threshold(config.anomaly_threshold)
      |> validate_interval(config.poll_interval_ms)
      |> validate_symbols(config.allowed_symbols)
      |> validate_quantity(config.max_quantity)
      |> validate_notional(config.max_notional)
      |> validate_deviation(config.price_deviation_pct)

    case errors do
      [] -> config
      _ -> raise ArgumentError, "Invalid TradeMonitor configuration: #{Enum.join(errors, ", ")}"
    end
  end

  defp fetch!(config, key) do
    case Keyword.fetch(config, key) do
      {:ok, value} -> value
      :error -> raise ArgumentError, "Missing required config: #{inspect(key)}"
    end
  end

  defp fetch_float!(config, key) do
    value = fetch!(config, key)

    cond do
      is_float(value) -> value
      is_integer(value) -> value * 1.0
      is_binary(value) -> String.to_float(value)
      true -> raise ArgumentError, "Expected float for #{inspect(key)}"
    end
  end

  defp fetch_integer!(config, key) do
    value = fetch!(config, key)

    cond do
      is_integer(value) -> value
      is_binary(value) -> String.to_integer(value)
      true -> raise ArgumentError, "Expected integer for #{inspect(key)}"
    end
  end

  defp fetch_list!(config, key) do
    value = fetch!(config, key)

    cond do
      is_list(value) -> value
      is_binary(value) -> String.split(value, ",", trim: true)
      true -> raise ArgumentError, "Expected list for #{inspect(key)}"
    end
  end

  defp validate_path(errors, path) do
    cond do
      is_binary(path) && String.trim(path) != "" -> errors
      true -> ["trade_source must be a non-empty path" | errors]
    end
  end

  defp validate_threshold(errors, threshold) when threshold > 0, do: errors
  defp validate_threshold(errors, _), do: ["anomaly_threshold must be > 0" | errors]

  defp validate_interval(errors, interval) when interval > 0, do: errors
  defp validate_interval(errors, _), do: ["poll_interval_ms must be > 0" | errors]

  defp validate_symbols(errors, symbols) when is_list(symbols) and length(symbols) > 0, do: errors
  defp validate_symbols(errors, _), do: ["allowed_symbols must be a non-empty list" | errors]

  defp validate_quantity(errors, qty) when qty > 0, do: errors
  defp validate_quantity(errors, _), do: ["max_quantity must be > 0" | errors]

  defp validate_notional(errors, notional) when notional > 0, do: errors
  defp validate_notional(errors, _), do: ["max_notional must be > 0" | errors]

  defp validate_deviation(errors, pct) when pct > 0 and pct < 1, do: errors
  defp validate_deviation(errors, _), do: ["price_deviation_pct must be between 0 and 1" | errors]
end
