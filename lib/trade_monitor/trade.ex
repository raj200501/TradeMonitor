defmodule TradeMonitor.Trade do
  @moduledoc """
  Represents a validated trade record.
  """

  @enforce_keys [:id, :symbol, :price, :quantity, :timestamp]
  defstruct @enforce_keys ++ [:venue, :side, :notional]

  @type t :: %__MODULE__{
          id: String.t(),
          symbol: String.t(),
          price: float(),
          quantity: pos_integer(),
          timestamp: DateTime.t(),
          venue: String.t() | nil,
          side: String.t() | nil,
          notional: float()
        }

  def from_map(%{
        "id" => id,
        "symbol" => symbol,
        "price" => price,
        "quantity" => quantity,
        "timestamp" => timestamp
      }) do
    with {:ok, price} <- cast_float(price),
         {:ok, quantity} <- cast_integer(quantity),
         {:ok, timestamp} <- cast_datetime(timestamp) do
      {:ok,
       %__MODULE__{
         id: to_string(id),
         symbol: to_string(symbol),
         price: price,
         quantity: quantity,
         timestamp: timestamp,
         venue: nil,
         side: nil,
         notional: price * quantity
       }}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  def from_map(%{} = raw) do
    required = ["id", "symbol", "price", "quantity", "timestamp"]
    missing = Enum.reject(required, &Map.has_key?(raw, &1))

    if missing == [] do
      {:error, "Invalid trade payload"}
    else
      {:error, "Missing fields: #{Enum.join(missing, ", ")}"}
    end
  end

  def enrich(%__MODULE__{} = trade, %{"venue" => venue, "side" => side}) do
    %{trade | venue: venue, side: side}
  end

  def enrich(%__MODULE__{} = trade, _), do: trade

  defp cast_float(value) when is_float(value), do: {:ok, value}
  defp cast_float(value) when is_integer(value), do: {:ok, value * 1.0}

  defp cast_float(value) when is_binary(value) do
    case Float.parse(value) do
      {float, _} -> {:ok, float}
      :error -> {:error, "Invalid price"}
    end
  end

  defp cast_float(_), do: {:error, "Invalid price"}

  defp cast_integer(value) when is_integer(value) and value > 0, do: {:ok, value}

  defp cast_integer(value) when is_float(value) and value > 0 do
    if value == Float.floor(value) do
      {:ok, trunc(value)}
    else
      {:error, "Invalid quantity"}
    end
  end

  defp cast_integer(value) when is_binary(value) do
    case Integer.parse(value) do
      {int, _} when int > 0 -> {:ok, int}
      _ -> {:error, "Invalid quantity"}
    end
  end

  defp cast_integer(_), do: {:error, "Invalid quantity"}

  defp cast_datetime(%DateTime{} = datetime), do: {:ok, datetime}

  defp cast_datetime(value) when is_binary(value) do
    case DateTime.from_iso8601(value) do
      {:ok, datetime, _offset} -> {:ok, datetime}
      _ -> {:error, "Invalid timestamp"}
    end
  end

  defp cast_datetime(_), do: {:error, "Invalid timestamp"}
end
